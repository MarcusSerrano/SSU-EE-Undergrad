import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# === FILL THESE IN WITH YOUR INFO ===
GMAIL_USER = "your_lab_gmail@gmail.com"
GMAIL_PASS = "your_16_char_app_password"
RECIPIENT_EMAIL = "where_you_want_to_receive@gmail.com"
# ====================================

def send_email(subject, body):
    msg = MIMEMultipart()
    msg["From"] = GMAIL_USER
    msg["To"] = RECIPIENT_EMAIL
    msg["Subject"] = subject
    msg.attach(MIMEText(body, "plain"))

    try:
        with smtplib.SMTP("smtp.gmail.com", 587) as smtpserver:
            smtpserver.ehlo()
            smtpserver.starttls()
            smtpserver.ehlo()
            smtpserver.login(GMAIL_USER, GMAIL_PASS)
            smtpserver.sendmail(GMAIL_USER, RECIPIENT_EMAIL, msg.as_string())
        print("Email sent successfully!")
    except Exception as e:
        print(f"Failed to send email: {e}")
