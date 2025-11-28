def get_cpu_temp_c():
    # Read the raw temperature from the system file
    with open("/sys/class/thermal/thermal_zone0/temp", "r") as f:
        temp_str = f.read().strip()   # e.g. '43752'

    # Convert from millidegrees C to degrees C
    temp_c = int(temp_str) / 1000.0
    return temp_c

if __name__ == "__main__":
    temp = get_cpu_temp_c()
    print(f"CPU temperature: {temp:.2f} °C")
