const dns = require('node:dns');
dns.setServers(['8.8.8.8', '1.1.1.1']); 


const path = require('path');
const express = require('express');
const helmet = require('helmet');
const session = require('express-session');
const { MongoStore } = require('connect-mongo');
const env = require('./config/env');
const { connectDatabase } = require('./config/database');
const authRoutes = require('./routes/web/authRoutes');
const dashboardRoutes = require('./routes/web/dashboardRoutes');
const hardwareRoutes = require('./routes/api/hardwareRoutes');
const mobileAppRouter = require('./routes/api/mobileAppRouter');
const companyAdminRoutes = require('./routes/api/companyAdminRoutes');
const realtimeRoutes = require('./routes/api/realtimeRoutes');
const morgan = require('morgan');

const { exposeSessionToViews } = require('./middlewares/authMiddleware');

const { notFoundHandler, errorHandler } = require('./middlewares/errorMiddleware');
const requestLogger = require('./middlewares/requestLogger');


const app = express();

// Allow all CORS for testing (disable/adjust in production)
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    // Some clients expect caching of preflight responses
    res.header('Access-Control-Max-Age', '86400');

    if (req.method === 'OPTIONS') {
        return res.sendStatus(200);
    }

    next();
});

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

app.use(
    helmet({
        contentSecurityPolicy: false,
        referrerPolicy: {
            policy: 'origin-when-cross-origin'
        }
    })
);

app.use(morgan('combined', {
    skip: (req) => req.path && req.path.startsWith('/public/')
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));
app.use(
    session({
        secret: env.sessionSecret,
        resave: false,
        saveUninitialized: false,
        store: MongoStore.create({
            mongoUrl: env.mongoUri,
            collectionName: 'sessions'
        }),
        cookie: {
            httpOnly: true,
            sameSite: 'lax',
            secure: env.nodeEnv === 'production',
            maxAge: 1000 * 60 * 60 * 8
        }
    })
);

app.use(exposeSessionToViews);
app.use(requestLogger);
app.use('/auth', authRoutes);

const busQrRoutes = require('./routes/api/busQrRoutes');

app.use('/api', hardwareRoutes);
app.use('/api/mobile', mobileAppRouter);
app.use('/api/company', companyAdminRoutes);
app.use('/api/realtime', realtimeRoutes);
app.use('/api/buses', busQrRoutes);
app.use('/', dashboardRoutes);




app.use(notFoundHandler);
app.use(errorHandler);

const HOST = process.env.HOST || '0.0.0.0';
const PORT = process.env.PORT || 3000;


async function bootstrap() {
    try {
        await connectDatabase();

app.listen(PORT, HOST, () => {
  console.log(`Server listening on port ${PORT}`);
});
    } catch (error) {
        console.error('Failed to start server:', error.message);
        process.exit(1);
    }
}

bootstrap();