-- sensor register
CREATE TABLE sensor_register (
 node_name VARCHAR(10) PRIMARY KEY,
 manufacturer VARCHAR(10) NOT NULL,
 longitude DECIMAL(15,8) CHECK (longitude BETWEEN -180 AND 180),
 latitude DECIMAL(15,8) CHECK (latitude BETWEEN -90 AND 90)
);
INSERT INTO sensor_register (node_name, manufacturer, longitude, latitude)
VALUES
('node_1', 'Bosch', -121.97800, 37.35530),
('node_2', 'Honeywell', -121.97910, 37.35640),
('node_3', 'Sensirion', -121.98020, 37.35750),
('node_4', 'Omron', -121.98130, 37.35860),
('node_5', 'Siemens', -121.98240, 37.35970);
-- sensor data section
CREATE TABLE sensor_data (
 node_name VARCHAR(10),
 time_received DATETIME,
 temperature DECIMAL(6,2) CHECK (temperature BETWEEN -10 AND 100),
 humidity DECIMAL(6,2) CHECK (humidity BETWEEN 0 AND 100),
 PRIMARY KEY (node_name, time_received),
 FOREIGN KEY (node_name) REFERENCES sensor_register(node_name)
);
INSERT INTO sensor_data (node_name, time_received, temperature, humidity)
VALUES
('node_1','2022-10-01 11:00:00',24.5,55.1),
('node_1','2022-10-01 11:30:00',25.0,54.3),
('node_1','2022-10-01 12:00:00',25.7,53.9),
('node_1','2022-10-01 12:30:00',26.1,52.8),
('node_2','2022-10-01 11:00:00',22.3,60.5),
('node_2','2022-10-01 11:30:00',22.8,59.2),
('node_2','2022-10-01 12:00:00',23.4,58.1),
('node_2','2022-10-01 12:30:00',24.1,57.0),
('node_3','2022-10-01 11:00:00',27.8,49.2),
('node_3','2022-10-01 11:30:00',28.4,48.5),
('node_3','2022-10-01 12:00:00',29.1,47.3),
('node_3','2022-10-01 12:30:00',29.8,46.8),
('node_4','2022-10-01 11:00:00',21.4,62.0),
('node_4','2022-10-01 11:30:00',21.9,61.1),
('node_4','2022-10-01 12:00:00',22.5,60.0),
('node_4','2022-10-01 12:30:00',23.1,59.2),
('node_5','2022-10-01 11:00:00',26.2,50.3),
('node_5','2022-10-01 11:30:00',26.9,49.9),
('node_5','2022-10-01 12:00:00',27.5,49.0),
('node_5','2022-10-01 12:30:00',28.1,48.5);