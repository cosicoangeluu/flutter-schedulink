-- Sample data for events table
INSERT INTO events (title, date, location, status, description) VALUES
('Digital Marketing Summit 2024', '2024-03-15', 'Convention Center', 'confirmed', 'A comprehensive summit on digital marketing strategies.'),
('Leadership Workshop Series', '2024-03-18', 'Business Hub', 'confirmed', 'Interactive workshops on leadership skills.'),
('Product Launch Webinar', '2024-03-22', 'Online', 'confirmed', 'Virtual launch event for our new product line.'),
('Customer Success Training', '2024-03-25', 'Training Room A', 'confirmed', 'Training session focused on customer success.'),
('Tech Conference 2024', '2024-04-01', 'Tech Park', 'confirmed', 'Annual tech conference with industry experts.'),
('Innovation Hackathon', '2024-04-05', 'Innovation Lab', 'pending', '48-hour hackathon for innovative solutions.'),
('Networking Mixer', '2024-04-10', 'Downtown Lounge', 'confirmed', 'Casual networking event for professionals.'),
('Data Science Bootcamp', '2024-04-15', 'University Campus', 'confirmed', 'Intensive bootcamp on data science fundamentals.');

-- Sample data for registrations table
-- Assuming event_ids correspond to the inserted events above
INSERT INTO registrations (event_id, participant_name, email, phone, organization, student_id) VALUES
(1, 'John Doe', 'john.doe@example.com', '123-456-7890', 'BSBA', '2021001'),
(1, 'Jane Smith', 'jane.smith@example.com', '123-456-7891', 'BSN', '2021002'),
(2, 'Alice Johnson', 'alice.johnson@example.com', '123-456-7892', 'CITHM', '2021003'),
(2, 'Bob Brown', 'bob.brown@example.com', '123-456-7893', 'BsCOE', '2021004'),
(3, 'Charlie Wilson', 'charlie.wilson@example.com', '123-456-7894', 'BSCS', '2021005'),
(3, 'Diana Davis', 'diana.davis@example.com', '123-456-7895', 'CTELA', '2021006'),
(4, 'Eve Evans', 'eve.evans@example.com', '123-456-7896', 'BSBA', '2021007'),
(4, 'Frank Foster', 'frank.foster@example.com', '123-456-7897', 'BSN', '2021008'),
(5, 'Grace Garcia', 'grace.garcia@example.com', '123-456-7898', 'CITHM', '2021009'),
(5, 'Henry Harris', 'henry.harris@example.com', '123-456-7899', 'BsCOE', '2021010'),
(6, 'Ivy Ingram', 'ivy.ingram@example.com', '123-456-7800', 'BSCS', '2021011'),
(6, 'Jack Jackson', 'jack.jackson@example.com', '123-456-7801', 'CTELA', '2021012'),
(7, 'Kate Kelly', 'kate.kelly@example.com', '123-456-7802', 'BSBA', '2021013'),
(7, 'Liam Lee', 'liam.lee@example.com', '123-456-7803', 'BSN', '2021014'),
(8, 'Mia Miller', 'mia.miller@example.com', '123-456-7804', 'CITHM', '2021015'),
(8, 'Noah Nelson', 'noah.nelson@example.com', '123-456-7805', 'BsCOE', '2021016'),
(1, 'Olivia Olson', 'olivia.olson@example.com', '123-456-7806', 'BSCS', '2021017'),
(2, 'Peter Parker', 'peter.parker@example.com', '123-456-7807', 'CTELA', '2021018'),
(3, 'Quinn Quinn', 'quinn.quinn@example.com', '123-456-7808', 'BSBA', '2021019'),
(4, 'Ryan Reed', 'ryan.reed@example.com', '123-456-7809', 'BSN', '2021020');
