import time
from email_alert import send_email  # uses the function you just wrote

def get_cpu_temp_c():
    with open("/sys/class/thermal/thermal_zone0/temp", "r") as f:
        temp_str = f.read().strip()
    return int(temp_str) / 1000.0

THRESHOLD_C = 40.0   # degrees Celsius

if __name__ == "__main__":
    while True:
        temp = get_cpu_temp_c()
        print(f"Current CPU temperature: {temp:.2f} °C")

        if temp > THRESHOLD_C:
            subject = f"RPI ALERT: CPU temp {temp:.1f} °C"
            body = (
                f"Warning! Your Raspberry Pi CPU temperature is {temp:.1f} °C,\n"
                f"which is above the threshold of {THRESHOLD_C:.1f} °C."
            )
            send_email(subject, body)

            # Avoid spamming yourself: wait a while after sending
            print("Alert sent. Sleeping 60 seconds to avoid spamming.")
            time.sleep(60)

        # Check every 10 seconds
        time.sleep(10)
