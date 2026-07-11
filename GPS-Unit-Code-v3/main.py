from machine import Pin, I2C, UART
import time
from lcd_i2c import LCD_I2C

# ══════════════════════════════════════════════════════════════════════════════
#  CONFIGURATION
# ══════════════════════════════════════════════════════════════════════════════

# BASE_URL          = "http://jalalfaour.alwaysdata.net"
BASE_URL          = "http://trackly.alwaysdata.net"

API_ENDPOINT      = BASE_URL + "/api/test/telegram"
APN               = "internet"           # ← change to your SIM card's APN
SEND_INTERVAL     = 10                   # seconds between HTTP posts
SMS_NUMBER        = "+963944886200"

# Device identity — sent in every HTTP request
COMPANY_API_SECRET = "aa580017-3701-470b-a5c4-f135a640d379"
DEVICE_ID          = "BUS-DEV-0001"
BUS_NUMBER         = "BUS-12"
ROUTE_ID           = "6a418f360983f556c32b611e"
CHAT_ID            = "869328361"

# ══════════════════════════════════════════════════════════════════════════════
#  HARDWARE INIT
# ══════════════════════════════════════════════════════════════════════════════

gps_uart = UART(1, baudrate=9600, tx=None, rx=Pin(9), timeout=100)
sim_uart = UART(0, baudrate=9600, tx=Pin(12), rx=Pin(13), timeout=100)

# Give SIM800L time to fully boot before we start talking to it.
# It needs up to 5s after power-on — this prevents the "stuck at baud rate"
# issue that happens when the Pico starts faster than the module.
print("Waiting for SIM800L to boot...")
time.sleep(5)

i2c = I2C(0, sda=Pin(4), scl=Pin(5), freq=100000)
lcd = LCD_I2C(i2c, cols=20, rows=4)

# ── LCD helpers ───────────────────────────────────────────────────────────────

def pad20(text):
    text = str(text)
    if len(text) >= 20:
        return text[:20]
    return text + " " * (20 - len(text))

def lcd_row(row, text):
    try:
        lcd.print(pad20(text), row=row)
    except OSError as e:
        print("LCD error row", row, ":", e)

# ── GPS helpers ───────────────────────────────────────────────────────────────

def nmea_to_decimal(val, direction):
    if not val:
        return None
    try:
        dot     = val.find('.')
        degrees = float(val[:dot - 2])
        minutes = float(val[dot - 2:])
        result  = degrees + (minutes / 60.0)
        if direction in ('S', 'W'):
            result = -result
        return round(result, 6)
    except Exception as e:
        print("GPS parse error:", e)
        return None

def read_gps():
    if not gps_uart.any():
        return None
    try:
        raw = gps_uart.readline()
        if not raw:
            return None
        sentence = raw.decode('utf-8', 'ignore').strip()
        if "$GNGGA" not in sentence and "$GPGGA" not in sentence:
            return None
        parts = sentence.split(',')
        if len(parts) < 10:
            return None
        sats = parts[7] or "0"
        if parts[2] and parts[4]:
            lat = nmea_to_decimal(parts[2], parts[3])
            lon = nmea_to_decimal(parts[4], parts[5])
            alt = parts[9] or "?"
            return (lat, lon, alt, sats)
        else:
            return (None, None, None, sats)
    except Exception as e:
        print("GPS read error:", e)
        return None

# ── SIM800L AT helpers ────────────────────────────────────────────────────────

def sim_send(cmd, wait=1.0):
    try:
        sim_uart.write((cmd + '\r\n').encode())
        time.sleep(wait)
        response_bytes = b""
        while sim_uart.any():
            chunk = sim_uart.read()
            if chunk:
                response_bytes += chunk
            time.sleep(0.05)
        response = response_bytes.decode('utf-8', 'replace').strip() if response_bytes else ""
        print("  >> " + cmd)
        print("  << " + (response if response else "(no response)"))
        return response
    except Exception as e:
        print("  !! sim_send error:", e)
        return ""

def sim_expect(cmd, expected, wait=1.0):
    return expected in sim_send(cmd, wait)

def sim_flush():
    time.sleep(0.2)
    while sim_uart.any():
        sim_uart.read()

def sim_set_baud(baud):
    global sim_uart
    sim_uart = UART(0, baudrate=baud, tx=Pin(12), rx=Pin(13), timeout=100)
    time.sleep(0.3)

def sim_auto_baud():
    rates = [9600, 115200, 19200, 38400, 57600]
    for baud in rates:
        print("[SIM] Trying baud rate " + str(baud) + "...")
        sim_set_baud(baud)
        sim_flush()
        for _ in range(3):
            sim_uart.write(b'AT\r\n')
            time.sleep(0.5)
        raw = sim_uart.read()
        response = raw.decode('utf-8', 'replace').strip() if raw else ""
        print("  << " + (response if response else "(no response)"))
        if "OK" in response:
            print("[SIM] Locked at " + str(baud) + " baud!")
            if baud != 9600:
                sim_uart.write(('AT+IPR=9600\r\n').encode())
                time.sleep(0.5)
                sim_set_baud(9600)
                sim_flush()
            return baud
    return None

def sim_wait_ready(retries=20):
    print("[SIM] Waiting for module to boot...")
    found_baud = sim_auto_baud()
    if found_baud:
        return True
    sim_set_baud(9600)
    for i in range(retries):
        sim_flush()
        response = sim_send("AT", wait=1.0)
        if "OK" in response:
            print("[SIM] Module is awake!")
            return True
        print("[SIM] Not ready yet, attempt " + str(i + 1) + "/" + str(retries))
        time.sleep(1)
    return False

def sim_init_gprs():
    """
    Initialise SIM card, wait for network registration, and bring up GPRS bearer.
    Returns True if GPRS is ready for HTTP.

    ⚡ POWER NOTE: AT+SAPBR=1,1 (bearer open) can spike up to 2A.
    Ensure a 1000µF cap across SIM800L VCC/GND and a 2A+ supply.
    """
    print("[SIM] Initialising GPRS...")
    sim_send("ATE0")
    sim_send("AT+CMEE=2")

    # Check SIM card
    if not sim_expect("AT+CPIN?", "READY", wait=2.0):
        print("[SIM] SIM card not ready")
        return False

    # Wait for network registration
    print("[SIM] Waiting for network registration...")
    for i in range(20):
        r = sim_send("AT+CREG?", wait=1.5)
        if ",1" in r or ",5" in r:
            print("[SIM] Registered on network!")
            break
        time.sleep(1)
    else:
        print("[SIM] Network registration failed")
        return False

    # Check signal quality (informational)
    sim_send("AT+CSQ")

    # Configure GPRS bearer
    sim_send('AT+SAPBR=3,1,"Contype","GPRS"', wait=1.0)
    sim_send('AT+SAPBR=3,1,"APN","' + APN + '"', wait=1.0)

    # Close bearer first in case it was left open from a previous crash
    sim_send("AT+SAPBR=0,1", wait=2.0)
    time.sleep(1)

    # Open bearer — this is the big current spike moment
    # ⚡ If your device resets here, your PSU can't supply enough current
    print("[SIM] Opening GPRS bearer (may spike current)...")
    r = sim_send("AT+SAPBR=1,1", wait=5.0)
    if "ERROR" in r:
        # Sometimes it's already open — check status
        r2 = sim_send("AT+SAPBR=2,1", wait=2.0)
        if ",1," not in r2:
            print("[SIM] Failed to open GPRS bearer")
            return False

    # Read assigned IP to confirm connection
    r = sim_send("AT+SAPBR=2,1", wait=2.0)
    print("[SIM] Bearer status: " + r)

    print("[SIM] GPRS ready!")
    return True

# ── HTTP POST ─────────────────────────────────────────────────────────────────

def build_iso_timestamp():
    """
    Build an ISO-8601 timestamp from the Pico's RTC.
    NOTE: The Pico has no battery-backed RTC — time resets on power cycle.
    If you have GPS time parsing you can improve this. For now it uses
    time.gmtime() which will show 2021-01-01 until an NTP sync happens.
    This is acceptable for the server to log; the server can override it.
    """
    t = time.gmtime()
    return "{:04d}-{:02d}-{:02d}T{:02d}:{:02d}:{:02d}.000Z".format(
        t[0], t[1], t[2], t[3], t[4], t[5]
    )

def build_json_body(lat, lon, speed=0):
    """
    Manually build JSON string — no json library in MicroPython by default.
    Keep it compact; every byte counts for AT+HTTPDATA length.
    """
    ts = build_iso_timestamp()
    body = (
        '{"apiSecret":"' + COMPANY_API_SECRET + '",'
        '"deviceId":"'   + DEVICE_ID          + '",'
        '"busNumber":"'  + BUS_NUMBER          + '",'
        '"routeId":"'    + ROUTE_ID            + '",'
        '"latitude":'    + str(lat)            + ','
        '"longitude":'   + str(lon)            + ','
        '"speed":'       + str(speed)          + ','
        '"timestamp":"'  + ts                  + '",'
        '"chatId":"'     + CHAT_ID             + '"}'
    )
    return body

def sim_wait_for(expected, timeout_ms=10000):
    """
    Non-blocking poll: read UART until expected string appears or timeout.
    Returns full accumulated response string.
    """
    response = ""
    deadline = time.ticks_add(time.ticks_ms(), timeout_ms)
    while time.ticks_diff(deadline, time.ticks_ms()) > 0:
        if sim_uart.any():
            raw = sim_uart.read(64)
            if raw:
                chunk = raw.decode('utf-8', 'replace')
                response += chunk
                print("  [rx] " + repr(chunk))
        if expected in response:
            break
        time.sleep(0.05)
    return response

def sim_http_post(lat, lon, speed=0):
    """
    Send a JSON POST request to the API endpoint using SIM800L AT+HTTP commands.
    Returns True on HTTP 200/201, False on any failure.

    ⚡ The bearer must already be open (sim_init_gprs called at boot).
    Re-opening the bearer mid-run is fine but causes another current spike.
    """
    body = build_json_body(lat, lon, speed)
    body_len = len(body)
    print("[HTTP] POST to: " + API_ENDPOINT)
    print("[HTTP] Body (" + str(body_len) + " bytes): " + body)

    sim_flush()

    # 1. Init HTTP stack
    r = sim_send("AT+HTTPINIT", wait=1.0)
    if "ERROR" in r:
        # Already initialised — terminate and retry once
        sim_send("AT+HTTPTERM", wait=1.0)
        time.sleep(0.5)
        r = sim_send("AT+HTTPINIT", wait=1.0)
        if "ERROR" in r:
            print("[HTTP] HTTPINIT failed")
            return False

    # 2. Link to bearer
    sim_send('AT+HTTPPARA="CID",1', wait=0.5)

    # 3. Set URL
    sim_send('AT+HTTPPARA="URL","' + API_ENDPOINT + '"', wait=1.0)

    # 4. Set Content-Type header
    sim_send('AT+HTTPPARA="CONTENT","application/json"', wait=0.5)

    # 5. Tell the module how many bytes we're about to send
    #    Timeout for data input is 10000ms (10 seconds)
    r = sim_send('AT+HTTPDATA=' + str(body_len) + ',10000', wait=1.0)
    if "DOWNLOAD" not in r:
        print("[HTTP] HTTPDATA did not get DOWNLOAD prompt, response: " + r)
        sim_send("AT+HTTPTERM", wait=1.0)
        return False

    # 6. Send the JSON body immediately after receiving DOWNLOAD prompt
    sim_uart.write(body.encode('utf-8'))
    print("[HTTP] Body sent, waiting for OK...")

    # Wait for the module to confirm it received the data
    r = sim_wait_for("OK", timeout_ms=5000)
    if "OK" not in r:
        print("[HTTP] Body not acknowledged")
        sim_send("AT+HTTPTERM", wait=1.0)
        return False

    # 7. Execute POST — AT+HTTPACTION=1
    #    Response comes back as +HTTPACTION: 1,<status_code>,<data_len>
    #    This can take several seconds over GPRS
    print("[HTTP] Executing POST (waiting up to 30s)...")
    sim_uart.write(('AT+HTTPACTION=1\r\n').encode())
    r = sim_wait_for("+HTTPACTION:", timeout_ms=30000)

    print("[HTTP] Action response: " + repr(r))

    # 8. Close HTTP stack regardless of outcome
    sim_send("AT+HTTPTERM", wait=1.0)

    # 9. Parse status code from "+HTTPACTION: 1,200,<len>"
    if "+HTTPACTION:" in r:
        try:
            # Extract everything after the colon
            after_colon = r.split("+HTTPACTION:")[1].strip().split("\n")[0]
            parts = after_colon.split(",")
            if len(parts) >= 2:
                status_code = int(parts[1].strip())
                print("[HTTP] Status code: " + str(status_code))
                if 200 <= status_code <= 299:
                    print("[HTTP] POST SUCCESS ✓")
                    return True
                else:
                    print("[HTTP] Server returned error: " + str(status_code))
                    return False
        except Exception as e:
            print("[HTTP] Parse error: " + str(e))

    print("[HTTP] POST FAILED ✗")
    return False

def sim_reopen_bearer():
    """
    Re-open the GPRS bearer if it dropped (happens after idle timeout ~60s on some networks).
    ⚡ Another current spike — same 2A concern applies.
    """
    print("[SIM] Re-opening GPRS bearer...")
    sim_send("AT+SAPBR=0,1", wait=2.0)
    time.sleep(1)
    r = sim_send("AT+SAPBR=1,1", wait=5.0)
    return "ERROR" not in r

def sim_bearer_alive():
    """Check if GPRS bearer is still connected without re-opening it."""
    r = sim_send("AT+SAPBR=2,1", wait=2.0)
    # Response: +SAPBR: 1,1,"<ip>"  (status 1 = connected)
    return ",1," in r

# ══════════════════════════════════════════════════════════════════════════════
#  BOOT SEQUENCE
# ══════════════════════════════════════════════════════════════════════════════

print("=" * 40)
print("GPS Tracking Unit")
print("=" * 40)

lcd.clear()
lcd_row(0, "GPS Unit v3.0")
lcd_row(1, "Booting...")
lcd_row(2, "")
lcd_row(3, "")
time.sleep(1)

lcd_row(1, "SIM: waking up...")
sim_ok = sim_wait_ready(retries=20)

if not sim_ok:
    print("[SIM] Module did not respond — GPS only mode")
    lcd_row(1, "SIM: NO RESPONSE")
    lcd_row(2, "Check wiring/power")
    time.sleep(3)
    http_ready = False
else:
    lcd_row(1, "SIM: init GPRS...")
    http_ready = sim_init_gprs()
    lcd_row(1, "SIM: " + ("GPRS OK!" if http_ready else "GPRS FAIL"))
    time.sleep(2)

# Flush GPS buffer
while gps_uart.any():
    gps_uart.read()

print("[GPS] Listening...")
lcd_row(0, "Bus Tracker")
lcd_row(1, "NET: " + ("OK" if http_ready else "FAIL"))
lcd_row(2, "GPS: searching...")
lcd_row(3, "")

# ══════════════════════════════════════════════════════════════════════════════
#  MAIN LOOP
# ══════════════════════════════════════════════════════════════════════════════

last_send_time  = 0
consecutive_fails = 0          # track failures to trigger bearer re-open

while True:
    gps_data = read_gps()

    if gps_data is not None:
        lat, lon, alt, sats = gps_data

        if lat is not None and lon is not None:
            print("[GPS] FIX | Sats:" + sats + " | " + str(lat) + "," + str(lon) + " | Alt:" + str(alt) + "m")
            print("      Maps: https://www.google.com/maps?q=" + str(lat) + "," + str(lon))

            lcd_row(0, "FIX  Sats: " + sats)
            lcd_row(1, "La: " + str(lat))
            lcd_row(2, "Lo: " + str(lon))
            lcd_row(3, "Alt: " + str(alt) + "m")

            now = time.time()
            if http_ready and (now - last_send_time) >= SEND_INTERVAL:

                # Check bearer is still alive before trying HTTP
                # (GPRS can drop after inactivity — re-open if needed)
                if not sim_bearer_alive():
                    lcd_row(3, "Reconnecting...")
                    http_ready = sim_reopen_bearer()
                    if not http_ready:
                        lcd_row(3, "NET: reconnect fail")
                        time.sleep(2)
                        continue

                lcd_row(3, "Sending HTTP...")
                ok = sim_http_post(lat, lon, speed=0)

                if ok:
                    lcd_row(3, "API: OK!")
                    consecutive_fails = 0
                else:
                    lcd_row(3, "API: FAILED")
                    consecutive_fails += 1
                    # After 3 consecutive failures, try re-opening the bearer
                    if consecutive_fails >= 3:
                        print("[SIM] 3 consecutive failures — re-opening bearer")
                        http_ready = sim_reopen_bearer()
                        consecutive_fails = 0

                last_send_time = now
                time.sleep(2)
                lcd_row(3, "Alt: " + str(alt) + "m")

        else:
            print("[GPS] Searching... Sats visible: " + sats)
            lcd_row(0, "GPS: searching...")
            lcd_row(1, "Sats visible: " + sats)
            lcd_row(2, "Waiting for fix")
            lcd_row(3, "NET: " + ("OK" if http_ready else "FAIL"))

    time.sleep(0.1)

