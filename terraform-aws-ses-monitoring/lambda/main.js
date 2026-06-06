const https = require("https");

const DD_ENV = process.env.DD_ENV || "dev";
const DD_API_KEY = process.env.DD_API_KEY;
const DD_SITE = process.env.DD_SITE || "us5.datadoghq.com";
const DD_SOURCE = process.env.DD_SOURCE || "lambda";
const DD_SERVICE = process.env.DD_SERVICE || "ses_outgoing_email_logs";

const DATADOG_LOG_URL = `https://http-intake.logs.${DD_SITE}/api/v2/logs`;

exports.handler = async (event) => {
    for (const record of event.Records) {
        const snsMessage = JSON.parse(record.Sns.Message);
        console.log(snsMessage);
        const notificationType = snsMessage?.notificationType;

        if (["Bounce", "Complaint", "Delivery"].includes(notificationType)) {
            const logData = JSON.stringify({
                ddsource: DD_SOURCE,
                service: DD_SERVICE,
                message: `SES Notification type ${notificationType} Received`,
                attributes: snsMessage,
                ddtags: `env:${DD_ENV}`
            });

            const url = new URL(DATADOG_LOG_URL);
            const options = {
                hostname: url.hostname,
                path: url.pathname + url.search,
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "DD-API-KEY": DD_API_KEY,
                    "Content-Length": Buffer.byteLength(logData)
                }
            };

            await new Promise((resolve, reject) => {
                const req = https.request(options, (res) => {
                    let data = "";
                    res.on("data", (chunk) => {
                        data += chunk;
                    });
                    res.on("end", () => {
                        console.log(`Logged SES ${notificationType} to Datadog`);
                        resolve();
                    });
                });

                req.on("error", (error) => {
                    console.error("Failed to send log to Datadog:", error.message);
                    reject(error);
                });

                req.write(logData);
                req.end();
            });
        } else {
            console.log(`Received unsupported SES notification type ${notificationType}`);
        }
    }

    return {
        statusCode: 200,
        body: JSON.stringify({ message: "success" })
    };
};
