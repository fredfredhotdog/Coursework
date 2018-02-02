/*
    David Cyphert   dac182
    Forbes Turley   [...]
    CS 2550 - Principles of Database Systems
    University of Pittsburgh - Spring 2018
    Due: 2/6/2018
*/

/* drop tables/sequences */
DECLARE cnt NUMBER;
BEGIN         
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'PARTICIPANT';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP TABLE PARTICIPANT';
    END IF;
    
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'MEMBER';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP TABLE MEMBER';
    END IF;
    
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'SPORT_TEAM';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP TABLE SPORT_TEAM';
    END IF;
    
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'ATHLETE';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP TABLE ATHLETE';
    END IF;
     
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'COUNTRY_TEAM';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP TABLE COUNTRY_TEAM';
    END IF;
    
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'EVENT';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP TABLE EVENT';
    END IF;
    
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'VENUE';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP TABLE VENUE';
    END IF;
    
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'SPORT';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP TABLE SPORT';
    END IF;
    
    SELECT COUNT(*) INTO cnt FROM user_sequences WHERE sequence_name = 'ATHLETE_SEQ';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP SEQUENCE ATHLETE_SEQ';
    END IF;
    
    SELECT COUNT(*) INTO cnt FROM user_sequences WHERE sequence_name = 'SPORT_SEQ';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP SEQUENCE SPORT_SEQ';
    END IF;
    
    SELECT COUNT(*) INTO cnt FROM user_sequences WHERE sequence_name = 'SPORT_TEAM_SEQ';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP SEQUENCE SPORT_TEAM_SEQ';
    END IF;
    
    SELECT COUNT(*) INTO cnt FROM user_sequences WHERE sequence_name = 'EVENT_SEQ';
    IF cnt <> 0 THEN
      EXECUTE IMMEDIATE 'DROP SEQUENCE EVENT_SEQ';
    END IF;
END;
/
/* END drop tables/sequences */
  
/* Question 1 */

CREATE TABLE SPORT (
    sport_no int NOT NULL,
    sport_name varchar(30),
    PRIMARY KEY(sport_no) DEFERRABLE
);

CREATE TABLE EVENT (
    event_no int NOT NULL,
    event_name varchar(30),
    sport_no int NOT NULL,
    venue_code varchar(3) NOT NULL,
    start_time date,
    spectators_count int,
    percentage float, 
    PRIMARY KEY(event_no) DEFERRABLE
);

CREATE TABLE VENUE (
    venue_code varchar(3) NOT NULL,
    venue_name varchar(30),
    capacity int,
    PRIMARY KEY (venue_code) DEFERRABLE
);

CREATE TABLE PARTICIPANT (
    event_no int NOT NULL,
    sport_team_no int NOT NULL,
    medal varchar(6)
);

CREATE TABLE SPORT_TEAM (
    sport_team_no int NOT NULL,
    country_team_code varchar(3) NOT NULL,
    PRIMARY KEY(sport_team_no) DEFERRABLE
);

CREATE TABLE COUNTRY_TEAM (
    country_team_code varchar(3) NOT NULL,
    country_name varchar(100),
    rank_in_2014 int,
    current_points int,
    PRIMARY KEY (country_team_code) DEFERRABLE
);

CREATE TABLE MEMBER (
    sport_team_no int NOT NULL,
    athlete_no int NOT NULL
);

CREATE TABLE ATHLETE (
    athlete_no int NOT NULL,
    full_name varchar(30),
    weight int,
    PRIMARY KEY (athlete_no) DEFERRABLE
);

ALTER TABLE EVENT
ADD CONSTRAINT FK_sport_event FOREIGN KEY (sport_no) REFERENCES SPORT(sport_no) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE EVENT
ADD CONSTRAINT FK_venue_event FOREIGN KEY (venue_code) REFERENCES VENUE(venue_code) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE EVENT
ADD CONSTRAINT check_percentage
CHECK (percentage <= 1.0) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE PARTICIPANT
ADD CONSTRAINT FK_event_participant FOREIGN KEY (event_no) REFERENCES EVENT(event_no) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE PARTICIPANT
ADD CONSTRAINT FK_sport_team_participant FOREIGN KEY (sport_team_no) REFERENCES SPORT_TEAM(sport_team_no) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE PARTICIPANT
ADD CONSTRAINT check_metal
CHECK (UPPER(medal) IN ('GOLD', 'SILVER', 'BRONZE', 'NONE')) DEFERRABLE INITIALLY IMMEDIATE;
  
ALTER TABLE MEMBER
ADD CONSTRAINT FK_sport_team_member FOREIGN KEY (sport_team_no) REFERENCES SPORT_TEAM(sport_team_no) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE MEMBER
ADD CONSTRAINT FK_athlete_member FOREIGN KEY (athlete_no) REFERENCES ATHLETE(athlete_no) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SPORT_TEAM
ADD CONSTRAINT FK_country_team_sport_team FOREIGN KEY (country_team_code) REFERENCES COUNTRY_TEAM(country_team_code) DEFERRABLE INITIALLY DEFERRED;

/* END Question 1 */

/* Question 2 */

/* 2a */
ALTER TABLE PARTICIPANT
ADD CONSTRAINT alt_participant UNIQUE(event_no, sport_team_no) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE MEMBER
ADD CONSTRAINT alt_member UNIQUE(sport_team_no, athlete_no) DEFERRABLE INITIALLY IMMEDIATE;

/* 2b */
ALTER TABLE SPORT_TEAM
ADD sport_no int NOT NULL CONSTRAINT FK_sport_sport_team REFERENCES SPORT(sport_no) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

/* 2c */
ALTER TABLE COUNTRY_TEAM
ADD CONSTRAINT check_rank_in_2014
CHECK ((rank_in_2014 = null) or (rank_in_2014 BETWEEN 1 and 26));

/* 2d */
ALTER TABLE ATHLETE
ADD dob date NOT NULL;

/* END Question 2 */

/* Question 3 */

ALTER SESSION SET PLSCOPE_SETTINGS = 'IDENTIFIERS:NONE';

CREATE OR REPLACE TRIGGER CheckSportTeamAthleteCount
  BEFORE INSERT OR UPDATE ON SPORT_TEAM
  FOR EACH ROW

DECLARE
    cnt number;
    action varchar(6);
BEGIN
    
    IF INSERTING THEN action := 'Insert';
    ELSE action := 'Update';
    END IF; 
    
    SELECT COUNT(*) INTO cnt FROM MEMBER
    WHERE sport_team_no = :new.sport_team_no;
    
    IF(cnt < 1) THEN
        raise_application_error(-20001, action||' failed. Sport team must have at least 1 athlete to represent a country team.');
    END IF;
END;
/

/* END Question 3 */

/* Question 4 */

INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('pos', 'PyeongChang Olympic Stadium', 35000);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('asj', 'Alpensia Ski Jumping Centre', 8500);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('abc', 'Alpensia Biathlon Centre', 7500);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('acc', 'Alpensia Cross-Country Centre', 7500);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('osc', 'Olympic Sliding Centre', 7000);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('yac', 'Yongpyong Alpine Centre', 6000);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('jac', 'Jeongseon Alpine Centre', 6500);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('psp', 'Phoenix Snow Park', 18000);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('ghc', 'Gangneung Hockey Centre', 10000);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('gao', 'Gangneung Oval', 8000);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('gia', 'Gangneung Ice Arena', 12000);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('gcc', 'Gangneung Curling Centre', 3000);
INSERT INTO VENUE (venue_code, venue_name, capacity) VALUES ('khc', 'Kwandong Hockey Centre', 6000);


INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('gre', 'Greece', NULL, 11);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('gha', 'Ghana', NULL, 12);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('ngr', 'Nigeria', NULL, 3);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('rsa', 'South Africa', NULL, 2);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('ned', 'Netherlands', 5, 4);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('nor', 'Norway', 1, 3);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('nlz', 'New Zealand', NULL, 2);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('den', 'Denmark', NULL, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('dma', 'Dominica', NULL, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('ger', 'Germany', 6, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('tls', 'Democratic Republic of Timor-Leste', NULL, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('lat', 'Latvia', 23, 2);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('lbn', 'Lebanon', NULL, 3);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('rou', 'Romania', NULL, 5);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('lux', 'Luxemburg', NULL, 9);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('ltu', 'Lithuania', NULL, 5);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('lie', 'Liechtenstein', NULL, 6);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('mad', 'Madagascar', NULL, 30);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('mas', 'Malaysia', NULL, 12);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('mex', 'Mexico', NULL, 23);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('mon', 'Monaco', NULL, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('mar', 'Morocco', NULL, 6);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('mne', 'Montenegro', NULL, 9);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('moa', 'Republic of Moldova', NULL, 6);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('mlt', 'Malta', NULL, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('mgl', 'Mongolia', NULL, 6);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('usa', 'United States of America', 3, 8);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('ber', 'Bermuda', NULL, 7);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('bel', 'Belgium', NULL, 6);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('blr', 'Belarus', 8, 7);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('bih', 'Bosnia and Herzegovina', NULL, 7);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('bol', 'Bolivia', NULL, 4);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('bul', 'Bulgaria', NULL, 0);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('bra', 'Brazil', NULL, 8);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('smr', 'San Marino', NULL, 8);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('srb', 'Serbia', NULL, 8);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('swe', 'Sweden', 14, 5);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('sui', 'Switzerland', 7, 10);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('esp', 'Spain', NULL, 7);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('svk', 'Slovakia', 21, 7);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('slo', 'Slovenia', 16, 5);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('sgp', 'Singapore', NULL, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('arm', 'Armenia', NULL, 2);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('arg', 'Argentina', NULL, 6);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('isl', 'Iceland', NULL, 5);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('irl', 'Ireland', NULL, 4);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('aze', 'Azerbaijan', NULL, 7);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('and', 'Andorra', NULL, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('alb', 'Albania', NULL, 10);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('eri', 'Eritrea', NULL, 2);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('est', 'Estonia', NULL, 2);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('ecu', 'Ecuador', NULL, 10);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('gbr', 'Great Britain', 19, 9);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('aus', 'Australia', 24, 3);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('aut', 'Austria', 9, 3);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('uzb', 'Uzbekistan', NULL, 0);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('ukr', 'Ukraine', 20, 5);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('iri', 'Islamic Republic of Iran', NULL, 8);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('ita', 'Italy', 22, 7);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('isr', 'Israel', NULL, 7);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('ind', 'India', NULL, 3);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('jpn', 'Japan', 17, 10);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('jam', 'Jamaica', NULL, 6);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('geo', 'Georgia', NULL, 4);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('chn', 'Peoplles Republic of China', 12, 4);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('cze', 'Czech Republic', 15, 8);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('chi', 'Chile', NULL, 10);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('kaz', 'Kazakhstan', 26, 9);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('can', 'Canada', 2, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('ken', 'Kenya', NULL, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('kos', 'Kosovo', NULL, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('col', 'Colombia', NULL, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('cro', 'Croatia', 25, 2);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('kgz', 'Kyrgyzstan', NULL, 9);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('cyp', 'Cyprus', NULL, 4);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('tpe', 'Chinese Taipei', NULL, 8);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('tha', 'Thailand', NULL, 9);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('tur', 'Turkey', NULL, 9);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('tog', 'Togo', NULL, 8);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('tga', 'Tonga', NULL, 9);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('pak', 'Pakistan', NULL, 2);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('por', 'Portugal', NULL, 5);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('pol', 'Poland', 11, 8);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('pur', 'Puerto Rico', NULL, 0);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('fra', 'France', 10, 9);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('mkd', 'The Former Yugoslav Republic of Macedonia', NULL, 8);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('fin', 'Finland', 18, 2);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('phi', 'Philippines', NULL, 1);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('hun', 'Hungary', NULL, 3);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('hkg', 'Hong Kong, China', NULL, 2);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('oar', 'Olympic Athletes from Russia', NULL, 5);
INSERT INTO COUNTRY_TEAM (country_team_code, country_name, rank_in_2014, current_points) VALUES ('cor', 'Korea', NULL, 7);


INSERT INTO SPORT (sport_no, sport_name) VALUES (1, 'Alpine skiing');
INSERT INTO SPORT (sport_no, sport_name) VALUES (2, 'Biathlon');
INSERT INTO SPORT (sport_no, sport_name) VALUES (3, 'Bobsleigh');
INSERT INTO SPORT (sport_no, sport_name) VALUES (4, 'Cross-country skiing');
INSERT INTO SPORT (sport_no, sport_name) VALUES (5, 'Curling');
INSERT INTO SPORT (sport_no, sport_name) VALUES (6, 'Figure skating');
INSERT INTO SPORT (sport_no, sport_name) VALUES (7, 'Freestyle skiing');
INSERT INTO SPORT (sport_no, sport_name) VALUES (8, 'Ice hockey');
INSERT INTO SPORT (sport_no, sport_name) VALUES (9, 'Luge');
INSERT INTO SPORT (sport_no, sport_name) VALUES (10, 'Nordic combined');
INSERT INTO SPORT (sport_no, sport_name) VALUES (11, 'Short track speed skating');
INSERT INTO SPORT (sport_no, sport_name) VALUES (12, 'Skeleton');
INSERT INTO SPORT (sport_no, sport_name) VALUES (13, 'Ski jumping');
INSERT INTO SPORT (sport_no, sport_name) VALUES (14, 'Snowboarding');
INSERT INTO SPORT (sport_no, sport_name) VALUES (15, 'Speed skating');


alter session set nls_date_format = 'mm/dd/yyyy';
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (1, 'Skylar Wyatt', 152, '07/18/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (2, 'Raschelle Davis', 180, '10/24/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (3, 'George Robinson', 274, '06/14/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (4, 'Jacki Handyside', 180, '11/4/1980');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (5, 'Jackson Hildyard', 121, '09/23/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (6, 'Alexandria Dunkle', 162, '3/3/1994');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (7, 'Callie Hall', 208, '01/22/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (8, 'Paget Wynter', 300, '10/3/1990');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (9, 'Don Wardle', 180, '1/2/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (10, 'Leah Garland', 180, '10/21/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (11, 'Pansy Ann', 175, '2/2/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (12, 'Jeni Knight', 272, '06/12/1994');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (13, 'Eleonor Langston', 237, '08/15/1986');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (14, 'Lola Hay', 173, '10/6/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (15, 'Cyan Neely', 248, '07/19/1990');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (16, 'Talbot Orbell', 293, '3/4/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (17, 'Maryanne Fischer', 137, '09/10/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (18, 'Russel Carbaugh', 133, '11/11/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (19, 'Eldreda Eiford', 207, '2/5/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (20, 'Pia Blair', 214, '05/10/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (21, 'Roxy Carter', 286, '5/3/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (22, 'Barnabas Mueller', 194, '06/25/1987');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (23, 'Katherina Cox', 169, '4/6/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (24, 'Lilith Oneal', 230, '7/1/1976');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (25, 'Zachary Rhodes', 239, '11/21/1978');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (26, 'Laverne Joyce', 203, '10/3/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (27, 'Kennedy Moore', 104, '06/14/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (28, 'Kermit Laborde', 207, '4/8/1998');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (29, 'Chester Donkin', 244, '9/1/1980');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (30, 'Emmet Priebe', 116, '01/15/1998');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (31, 'Jaclyn Philbrick', 110, '7/5/1998');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (32, 'Waylon Jackson', 217, '10/7/1996');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (33, 'Donnie Ring', 119, '11/15/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (34, 'Alger Judge', 213, '02/13/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (35, 'Eglantine Parrish', 200, '7/7/1976');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (36, 'Seraphina Cable', 103, '01/13/1995');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (37, 'Nancy Arthur', 270, '12/31/1998');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (38, 'Deniece Widaman', 148, '09/10/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (39, 'Griffin Beck', 106, '08/26/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (40, 'Taylor Howard', 221, '10/29/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (41, 'Sonia Jolce', 242, '8/1/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (42, 'Ralphie Fry', 121, '3/4/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (43, 'Georgie Gardner', 250, '08/16/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (44, 'Jenelle Owens', 156, '07/31/1987');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (45, 'Mort Zadovsky', 150, '05/17/1994');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (46, 'Denis Werry', 103, '03/12/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (47, 'Victor Pirl', 272, '05/18/1996');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (48, 'Roydon Woodworth', 267, '9/8/1986');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (49, 'Jaden Wood', 121, '06/28/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (50, 'Justina Robertson', 273, '11/23/1995');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (51, 'Paise Wiggins', 144, '04/21/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (52, 'Beth Newton', 240, '06/22/1980');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (53, 'Adria Stange', 239, '09/25/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (54, 'Camden Stern', 224, '10/10/1985');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (55, 'Zavanna Bishop', 162, '07/18/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (56, 'Martie Herndon', 226, '03/29/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (57, 'Lauraine Pittman', 184, '05/30/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (58, 'Charlton Adams', 251, '1/9/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (59, 'Branden Bickerson', 136, '10/20/1996');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (60, 'Tansy Draudy', 219, '08/27/1996');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (61, 'Mitchell Kalp', 154, '07/24/1990');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (62, 'Milton Mccallum', 168, '12/12/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (63, 'Idony Nash', 251, '04/28/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (64, 'Lovel Geddinge', 204, '8/6/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (65, 'Richendra Lotherington', 152, '04/30/1980');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (66, 'Ed Hirleman', 157, '06/25/1996');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (67, 'Logan Greif', 105, '11/10/1995');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (68, 'Oneida Toulmin', 179, '03/26/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (69, 'Dalia Gottwine', 181, '4/9/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (70, 'Eveline Winton', 139, '03/10/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (71, 'Nikole Osteen', 204, '10/25/1986');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (72, 'Trista Fleming', 167, '10/19/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (73, 'Allen Ream', 127, '01/20/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (74, 'Gabriel Watson', 152, '05/14/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (75, 'Becky Anderson', 160, '6/3/1987');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (76, 'Allycia Wheeler', 118, '09/12/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (77, 'Hilda Conkle', 167, '03/14/1978');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (78, 'Lynnette Maclagan', 217, '09/22/1985');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (79, 'Alexa Wildman', 271, '10/3/1995');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (80, 'Latasha Cady', 129, '12/11/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (81, 'Redd Hoenshell', 128, '10/4/1978');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (82, 'Anjelica Buttermore', 252, '8/5/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (83, 'Dominick Kuster', 184, '02/16/1997');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (84, 'Alannis Jube', 179, '12/26/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (85, 'Linton Unk', 233, '07/27/1997');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (86, 'Nerissa Wile', 239, '11/7/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (87, 'Rolland Ramos', 116, '9/3/1997');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (88, 'Daly Sanner', 250, '8/5/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (89, 'Sukie Baskett', 169, '05/16/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (90, 'Garry Breitenstein', 200, '3/2/1987');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (91, 'Damon Goldvogel', 235, '09/24/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (92, 'Stu Stiffey', 252, '01/29/1978');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (93, 'Johnathan Schofield', 215, '12/27/1986');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (94, 'Roland Owen', 290, '08/31/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (95, 'Gilbert Tillson', 203, '3/4/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (96, 'Theresa Reese', 288, '12/18/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (97, 'Algar Porter', 116, '10/10/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (98, 'Ida Burns', 291, '10/1/1998');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (99, 'Fina Shotts', 107, '2/8/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (100, 'Pace Whiteman', 264, '11/2/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (101, 'Alec Eisenhart', 208, '4/3/1996');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (102, 'Shana Zalack', 128, '04/26/1998');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (103, 'Mckenzie Houser', 296, '07/27/1986');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (104, 'Coriander Gleper', 290, '06/11/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (105, 'Tiger Ewing', 116, '7/5/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (106, 'Cornelia Laurenzi', 231, '03/18/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (107, 'Edweena Hastings', 130, '05/10/1994');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (108, 'Rina Painter', 100, '11/18/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (109, 'Booker Compton', 138, '01/25/1990');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (110, 'Lorene Leslie', 201, '01/15/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (111, 'Gayle James', 253, '04/16/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (112, 'Donald Reighner', 277, '02/11/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (113, 'Krista Queer', 111, '04/21/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (114, 'Travers Stanfield', 256, '04/23/1994');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (115, 'Greig Kellogg', 191, '02/21/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (116, 'Royale Lear', 277, '12/1/1996');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (117, 'Raymund Jesse', 142, '05/18/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (118, 'Janis Hawker', 292, '4/7/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (119, 'Coral Prescott', 191, '7/8/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (120, 'Tanya Carden', 227, '11/8/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (121, 'Gwendolyn Lombardi', 177, '11/25/1990');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (122, 'Tarina Jenkins', 175, '11/6/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (123, 'Giles Bailey', 190, '11/20/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (124, 'Ernesta Dugmore', 167, '12/14/1987');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (125, 'Almira Adams', 215, '12/29/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (126, 'Doris Omara', 222, '01/22/1980');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (127, 'Shiloh Carmichael', 132, '11/13/1997');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (128, 'Kaitlin Sandblom', 175, '08/10/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (129, 'Cecil Glover', 113, '02/25/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (130, 'Eleanor Batten', 129, '10/6/1994');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (131, 'Jamie Higgens', 126, '3/5/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (132, 'Rowena Fisher', 219, '06/20/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (133, 'Keshawn Wegley', 298, '06/18/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (134, 'Luana Buck', 134, '03/19/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (135, 'Rue Woodward', 290, '08/19/1986');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (136, 'Yaron Ritter', 261, '5/5/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (137, 'Christobel Fisher', 253, '09/23/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (138, 'Terry Milne', 222, '08/30/1987');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (139, 'Lexi Poley', 255, '3/9/1990');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (140, 'Roscoe Bould', 151, '2/2/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (141, 'Kody Schuth', 279, '07/30/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (142, 'Ivy Holtzer', 173, '05/19/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (143, 'Julian Stainforth', 110, '03/22/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (144, 'Rexana Koster', 150, '12/14/1976');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (145, 'Isidora Blaine', 141, '6/2/1985');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (146, 'Selwyn Wilkerson', 298, '2/6/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (147, 'Zacharias Barr', 130, '09/30/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (148, 'France Leach', 200, '01/26/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (149, 'Evalyn Fraser', 192, '10/9/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (150, 'Masterman Fylbrigg', 155, '12/24/1990');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (151, 'Raphaela Ray', 116, '2/2/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (152, 'Geraldine Rawls', 246, '08/18/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (153, 'Carrie Haverrman', 112, '1/2/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (154, 'Creighton Pearson', 102, '12/22/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (155, 'Avril Trovato', 268, '06/22/1990');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (156, 'Sheard Simpson', 188, '12/23/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (157, 'Lavone Coldsmith', 121, '6/3/1997');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (158, 'Benjy Woollard', 238, '09/13/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (159, 'Aldous Steele', 278, '2/4/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (160, 'Joey Gilman', 203, '01/21/1996');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (161, 'Washington Mang', 156, '02/13/1978');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (162, 'Margaretta Lineman', 233, '9/5/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (163, 'Cheyenne Wade', 141, '07/29/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (164, 'India Moore', 146, '06/29/1996');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (165, 'Porter Bode', 198, '07/20/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (166, 'Rosie Meyers', 266, '12/24/1990');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (167, 'Toby Harding', 167, '6/7/1985');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (168, 'Genista Stoddard', 229, '03/13/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (169, 'Mansel Tripp', 162, '02/21/1985');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (170, 'Deidra Quirin', 209, '12/9/1996');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (171, 'Elvin Ropes', 206, '04/29/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (172, 'Gemma Southern', 261, '04/30/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (173, 'Joandra Garneys', 112, '12/27/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (174, 'Lakeisha Joghs', 194, '05/23/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (175, 'Kassandra Davis', 263, '10/8/1997');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (176, 'Nelson Eisenman', 111, '03/22/1987');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (177, 'Tricia Nickolson', 278, '11/22/1980');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (178, 'Lucky Mercer', 295, '08/26/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (179, 'Kathleen Zundel', 192, '5/4/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (180, 'Brianne Hill', 129, '02/12/1995');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (181, 'Zoie Flanders', 257, '12/28/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (182, 'Aaron Spring', 103, '11/29/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (183, 'Fitz Hobbs', 195, '04/30/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (184, 'Camilla Ling', 128, '08/12/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (185, 'Chance Mcintosh', 204, '8/1/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (186, 'Kipling Rosensteel', 177, '08/20/1976');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (187, 'Unity Maugham', 158, '7/4/1976');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (188, 'Christine Nabholz', 226, '9/4/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (189, 'Keith Tedrow', 260, '10/11/1995');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (190, 'Algernon Oppenheimer', 271, '12/19/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (191, 'Zelda Blessig', 186, '06/13/1986');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (192, 'Caelie Wolff', 118, '12/24/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (193, 'Guinevere Ruhl', 292, '4/6/1986');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (194, 'Lynne Romanoff', 210, '06/25/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (195, 'Winston Stewart', 223, '06/21/1995');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (196, 'Lina Boyd', 289, '12/24/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (197, 'Delbert Ullman', 261, '9/5/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (198, 'Andrea Faast', 118, '06/10/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (199, 'Jake Marriman', 193, '10/14/1976');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (200, 'July Feufer', 190, '11/12/1997');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (201, 'Marilynn Hunter', 197, '05/28/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (202, 'Karenza Mckendrick', 220, '5/9/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (203, 'Nell Ashbaugh', 185, '06/28/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (204, 'Marjory Shallenberger', 117, '04/25/1997');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (205, 'Peace Whishaw', 233, '07/29/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (206, 'Dena Osterwise', 177, '09/26/1976');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (207, 'Maybelline James', 201, '12/17/1986');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (208, 'Baylee Rahl', 161, '06/28/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (209, 'Tonya Bellinger', 136, '03/18/1985');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (210, 'Patience Osteen', 109, '5/3/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (211, 'Deanne Law', 240, '04/29/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (212, 'Mandy Lacon', 253, '04/29/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (213, 'Sigmund Kettlewell', 213, '8/5/1995');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (214, 'Cristal Dryfus', 271, '11/1/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (215, 'Ebba Atkinson', 212, '6/4/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (216, 'Hopkin Schmiel', 286, '06/17/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (217, 'Rachelle Newlove', 110, '03/28/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (218, 'Clay Marcotte', 174, '01/20/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (219, 'Alexandrea Whitling', 221, '6/2/1997');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (220, 'Sharona Hatherly', 191, '02/27/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (221, 'Maurine Isaman', 138, '3/9/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (222, 'Sibilla Blackburn', 175, '05/25/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (223, 'Nina Garratt', 134, '04/25/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (224, 'Wymond Hunt', 239, '5/3/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (225, 'Jenifer Sommer', 142, '07/30/1995');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (226, 'Allannah Reade', 195, '12/20/1997');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (227, 'Eunice Fuchs', 139, '12/24/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (228, 'Charles Elliott', 181, '12/10/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (229, 'Leigh Treeby', 264, '07/26/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (230, 'Dortha Beard', 274, '05/15/1978');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (231, 'Linda Hays', 149, '05/12/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (232, 'Gerry Close', 140, '09/11/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (233, 'Shanene Hills', 102, '01/28/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (234, 'Isaac Branson', 210, '09/24/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (235, 'Casimir Erschoff', 138, '07/23/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (236, 'Dalton Saylor', 211, '7/5/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (237, 'Ashlie Chauvin', 197, '05/18/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (238, 'Shantae Trout', 147, '9/5/1995');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (239, 'Allyson Durstine', 263, '6/8/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (240, 'Bailey Paul', 207, '4/6/1978');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (241, 'Allegra Schmidt', 227, '01/19/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (242, 'Haley Overstreet', 180, '03/23/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (243, 'Zillah Kimmons', 124, '12/5/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (244, 'Donny Swarner', 113, '7/5/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (245, 'Jude Seelig', 282, '11/26/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (246, 'Camellia Ramsey', 280, '12/18/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (247, 'Nikki Swabey', 216, '08/29/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (248, 'Danielle Cattley', 135, '2/4/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (249, 'Gwenevere Woolery', 133, '02/25/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (250, 'Lucia Gettemy', 135, '12/18/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (251, 'Joe Filby', 240, '09/14/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (252, 'Wilfred Jyllian', 150, '12/6/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (253, 'Glory Pinney', 262, '6/3/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (254, 'Netta Porter', 246, '01/11/1985');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (255, 'Polly Hahn', 279, '11/9/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (256, 'Iris Sybilla', 288, '06/17/1994');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (257, 'Divina Rockwell', 113, '5/9/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (258, 'Dolph Adcock', 218, '06/10/1977');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (259, 'Lula Sanders', 130, '06/15/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (260, 'Chadwick Mcelroy', 205, '12/21/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (261, 'Summer Roche', 278, '03/12/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (262, 'Latonya Burch', 189, '05/13/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (263, 'Reena Eva', 272, '4/8/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (264, 'William Snyder', 200, '12/12/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (265, 'Bertha Metzer', 259, '08/17/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (266, 'Willow Warrick', 232, '11/2/1981');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (267, 'Lesly Thomlinson', 198, '12/1/1994');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (268, 'Tessa Sutorius', 229, '01/22/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (269, 'Shawnda Overholt', 292, '08/22/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (270, 'Sabella Ammons', 105, '11/4/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (271, 'Ora Wynne', 132, '4/3/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (272, 'Liza Schreckengost', 202, '9/6/1982');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (273, 'Cole Bauerle', 178, '03/21/1998');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (274, 'Garrick Rose', 170, '11/23/1980');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (275, 'Zeph Griffis', 132, '01/25/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (276, 'Laurena Mcdonald', 157, '10/26/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (277, 'Monte Mcclymonds', 288, '6/7/1983');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (278, 'Davey Cason', 205, '04/19/1980');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (279, 'Cortney Loewentsein', 247, '05/17/1998');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (280, 'Buddy Hayhurst', 234, '09/14/1980');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (281, 'Alton Tomey', 195, '08/27/1987');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (282, 'Cedar Crawford', 160, '09/13/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (283, 'Branda Weeks', 295, '05/28/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (284, 'Norton Harshman', 182, '03/29/1984');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (285, 'Goodwin Hughes', 266, '10/24/1998');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (286, 'Quincy Fea', 273, '09/20/1991');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (287, 'Ern Dimsdale', 226, '08/31/1993');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (288, 'Keysha Mens', 149, '1/9/1987');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (289, 'Regan Whittier', 170, '06/19/1994');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (290, 'Steve Sloan', 203, '06/19/1989');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (291, 'Elicia Blatenberger', 199, '09/15/1980');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (292, 'Vincent Shirey', 163, '10/17/1975');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (293, 'Dorian Diegel', 157, '07/24/1987');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (294, 'Mable Mckee', 103, '1/4/1999');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (295, 'Davida Cross', 125, '12/30/1997');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (296, 'Desdemona Sanforth', 166, '03/12/1979');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (297, 'Poldie Mosser', 117, '08/17/1978');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (298, 'Gladys Marjorie', 129, '07/21/1988');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (299, 'Elouise Birdsall', 109, '05/22/1992');
INSERT INTO ATHLETE (athlete_no, full_name, weight, dob) VALUES (300, 'Liana Huston', 200, '03/27/1993');


alter session set nls_date_format = 'mm/dd/yy hh12:mi AM';
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (1,'Downhill',1,'jac','02/11/18 11:00 AM',3000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (2,'Slalom',1,'yac','02/12/18 10:15 AM',3000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (3,'Combined',1,'jac','02/13/18 11:30 AM',6000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (4,'Sprint',2,'abc','02/11/18 08:15 PM',7000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (5,'Pursuit',2,'abc','02/12/18 07:10 PM',5000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (6,'Two-man runs',3,'osc','02/19/18 08:15 PM',6900, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (7,'Four-man runs',3,'osc','02/25/18 09:30 AM',3000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (8,'10 km classical',4,'acc','02/13/18 05:30 PM',2000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (9,'Relay',4,'acc','02/18/18 03:15 PM',1000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (10,'Curling game',5,'gcc','02/23/18 03:35 PM',2000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (11,'Ice dance',6,'gia','02/12/18 10:00 AM',10000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (12,'Slopestyle',7,'psp','02/17/18 01:00 PM',15000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (13,'Aerials',7,'psp','02/16/18 08:00 PM',9000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (14,'Hockey game',8,'ghc','02/22/18 01:10 PM',9000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (15,'Doubles runs',9,'osc','02/14/18 08:20 PM',5000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (16,'Large hill',10,'asj','02/22/18 04:30 PM',6000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (17,'1000 metres',11,'gia','02/17/18 07:00 PM',2000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (18,'Singles runs',12,'osc','02/16/18 09:30 AM',4000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (19,'Normal hill',13,'asj','02/10/18 09:35 PM',7000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (20,'Parallel slalom',14,'psp','02/24/18 01:00 PM',1000, NULL);
INSERT INTO EVENT (event_no, event_name, sport_no, venue_code, start_time, spectators_count, percentage) VALUES (21,'5000 meters',15,'gao','02/11/18 04:00 PM',10000, NULL);


INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (1,1,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (1,2,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (1,3,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (1,4,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (2,5,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (2,6,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (2,7,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (2,8,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (2,9,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (3,10,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (3,11,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (3,12,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (3,13,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (3,14,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (3,15,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (4,16,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (4,17,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (4,18,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (4,19,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (5,20,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (5,21,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (5,22,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (5,23,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (5,24,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (5,25,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (5,26,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (6,27,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (6,28,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (6,29,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (7,30,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (7,31,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (7,32,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (8,33,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (8,34,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (8,35,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (9,36,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (9,37,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (9,38,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (9,39,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (10,40,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (10,41,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (10,42,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (10,43,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (10,44,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (10,45,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (11,46,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (11,47,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (12,48,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (12,49,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (12,50,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (12,51,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (13,52,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (13,53,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (14,54,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (14,55,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (14,56,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (14,57,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (14,58,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (14,59,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (15,60,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (15,61,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (15,62,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (16,63,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (16,64,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (16,65,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (16,66,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (17,67,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (17,68,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (18,69,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (18,70,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (18,71,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (19,72,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (19,73,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (20,74,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (20,75,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (20,76,'bronze');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (20,77,'none');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (21,78,'gold');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (21,79,'silver');
INSERT INTO PARTICIPANT (event_no, sport_team_no, medal) VALUES (21,80,'bronze');


INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (62, 1);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (50, 2);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (6, 3);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (1, 4);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (76, 5);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (18, 6);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (24, 7);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (48, 8);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (75, 9);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (72, 10);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (35, 11);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (51, 12);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (27, 13);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (75, 14);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (38, 15);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (7, 16);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (22, 17);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (65, 18);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (43, 19);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (46, 20);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (29, 21);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (11, 22);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (34, 23);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (52, 24);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (51, 25);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (19, 26);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (31, 27);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (25, 28);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (23, 29);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (20, 30);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (74, 31);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (18, 32);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (49, 33);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (11, 34);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (2, 35);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (73, 36);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (50, 37);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (74, 38);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (47, 39);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (5, 40);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (51, 41);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (44, 42);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (66, 43);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (62, 44);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (4, 45);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (28, 46);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (66, 47);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (53, 48);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (46, 49);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (27, 50);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (66, 51);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (65, 52);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (21, 53);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (76, 54);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (8, 55);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (15, 56);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (32, 57);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (8, 58);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (43, 59);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (23, 60);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (45, 61);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (17, 62);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (15, 63);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (4, 64);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (16, 65);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (36, 66);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (27, 67);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (2, 68);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (66, 69);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (20, 70);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (6, 71);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (77, 72);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (3, 73);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (1, 74);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (35, 75);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (76, 76);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (49, 77);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (71, 78);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (26, 79);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (73, 80);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (18, 81);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (35, 82);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (20, 83);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (51, 84);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (53, 85);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (4, 86);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (14, 87);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (63, 88);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (73, 89);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (80, 90);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (42, 91);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (31, 92);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (71, 93);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (50, 94);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (22, 95);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (44, 96);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (57, 97);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (11, 98);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (30, 99);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (4, 100);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (38, 101);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (65, 102);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (76, 103);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (74, 104);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (79, 105);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (13, 106);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (43, 107);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (11, 108);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (28, 109);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (54, 110);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (72, 111);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (17, 112);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (43, 113);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (68, 114);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (50, 115);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (15, 116);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (54, 117);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (72, 118);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (68, 119);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (1, 120);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (39, 121);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (56, 122);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (54, 123);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (75, 124);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (39, 125);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (38, 126);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (56, 127);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (58, 128);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (52, 129);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (46, 130);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (11, 131);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (14, 132);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (36, 133);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (77, 134);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (46, 135);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (16, 136);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (25, 137);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (33, 138);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (62, 139);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (9, 140);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (11, 141);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (74, 142);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (80, 143);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (63, 144);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (27, 145);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (19, 146);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (64, 147);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (44, 148);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (19, 149);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (12, 150);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (6, 151);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (17, 152);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (51, 153);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (48, 154);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (19, 155);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (74, 156);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (70, 157);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (38, 158);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (45, 159);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (60, 160);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (7, 161);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (50, 162);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (39, 163);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (14, 164);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (56, 165);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (61, 166);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (21, 167);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (42, 168);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (65, 169);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (74, 170);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (53, 171);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (13, 172);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (72, 173);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (10, 174);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (49, 175);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (76, 176);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (27, 177);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (68, 178);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (61, 179);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (12, 180);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (73, 181);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (46, 182);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (28, 183);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (13, 184);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (77, 185);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (48, 186);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (74, 187);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (17, 188);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (27, 189);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (4, 190);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (9, 191);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (46, 192);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (77, 193);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (37, 194);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (28, 195);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (7, 196);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (53, 197);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (58, 198);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (66, 199);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (29, 200);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (67, 201);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (37, 202);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (78, 203);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (40, 204);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (32, 205);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (63, 206);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (76, 207);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (69, 208);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (14, 209);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (8, 210);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (22, 211);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (73, 212);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (40, 213);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (38, 214);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (17, 215);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (65, 216);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (37, 217);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (72, 218);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (39, 219);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (15, 220);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (1, 221);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (2, 222);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (3, 223);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (4, 224);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (5, 225);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (6, 226);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (7, 227);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (8, 228);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (9, 229);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (10, 230);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (11, 231);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (12, 232);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (13, 233);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (14, 234);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (15, 235);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (16, 236);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (17, 237);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (18, 238);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (19, 239);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (20, 240);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (21, 241);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (22, 242);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (23, 243);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (24, 244);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (25, 245);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (26, 246);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (27, 247);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (28, 248);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (29, 249);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (30, 250);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (31, 251);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (32, 252);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (33, 253);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (34, 254);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (35, 255);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (36, 256);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (37, 257);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (38, 258);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (39, 259);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (40, 260);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (41, 261);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (42, 262);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (43, 263);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (44, 264);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (45, 265);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (46, 266);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (47, 267);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (48, 268);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (49, 269);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (50, 270);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (51, 271);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (52, 272);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (53, 273);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (54, 274);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (55, 275);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (56, 276);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (57, 277);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (58, 278);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (59, 279);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (60, 280);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (61, 281);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (62, 282);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (63, 283);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (64, 284);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (65, 285);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (66, 286);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (67, 287);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (68, 288);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (69, 289);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (70, 290);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (71, 291);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (72, 292);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (73, 293);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (74, 294);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (75, 295);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (76, 296);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (77, 297);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (78, 298);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (79, 299);
INSERT INTO MEMBER (sport_team_no, athlete_no) VALUES (80, 300);


INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (1, 'nor', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (2, 'ger', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (3, 'can', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (4, 'usa', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (5, 'aut', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (6, 'oar', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (7, 'cor', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (8, 'chn', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (9, 'swe', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (10, 'fra', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (11, 'chi', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (12, 'nlz', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (13, 'cze', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (14, 'pol', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (15, 'ita', 1);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (16, 'jpn', 2);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (17, 'fin', 2);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (18, 'aus', 2);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (19, 'blr', 2);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (20, 'svk', 2);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (21, 'cro', 2);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (22, 'sgp', 2);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (23, 'lbn', 2);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (24, 'gbr', 2);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (25, 'est', 2);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (26, 'kaz', 2);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (27, 'geo', 3);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (28, 'bra', 3);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (29, 'ukr', 3);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (30, 'jam', 3);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (31, 'usa', 3);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (32, 'ger', 3);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (33, 'can', 4);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (34, 'nor', 4);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (35, 'aut', 4);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (36, 'oar', 4);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (37, 'cor', 4);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (38, 'chn', 4);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (39, 'swe', 4);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (40, 'fra', 5);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (41, 'chi', 5);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (42, 'nlz', 5);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (43, 'cze', 5);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (44, 'pol', 5);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (45, 'ita', 5);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (46, 'jpn', 6);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (47, 'fin', 6);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (48, 'aus', 7);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (49, 'blr', 7);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (50, 'svk', 7);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (51, 'cro', 7);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (52, 'sgp', 7);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (53, 'lbn', 7);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (54, 'oar', 8);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (55, 'est', 8);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (56, 'kaz', 8);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (57, 'geo', 8);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (58, 'bra', 8);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (59, 'ukr', 8);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (60, 'jam', 9);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (61, 'gbr', 9);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (62, 'usa', 9);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (63, 'ger', 10);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (64, 'can', 10);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (65, 'nor', 10);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (66, 'aut', 10);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (67, 'oar', 11);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (68, 'cor', 11);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (69, 'chn', 12);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (70, 'swe', 12);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (71, 'fra', 12);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (72, 'usa', 13);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (73, 'ger', 13);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (74, 'can', 14);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (75, 'nor', 14);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (76, 'aut', 14);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (77, 'oar', 14);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (78, 'cor', 15);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (79, 'chn', 15);
INSERT INTO SPORT_TEAM (sport_team_no, country_team_code, sport_no) VALUES (80, 'swe', 15);

/* END Question 4 */

/* create sequences for numeric keys */
DECLARE
    SEQ INTEGER;
BEGIN
    SELECT MAX(ATHLETE_NO) INTO SEQ FROM ATHLETE;
    
    EXECUTE IMMEDIATE 'CREATE SEQUENCE ATHLETE_SEQ
                       START WITH ' || SEQ ||
                       ' INCREMENT BY 1';
                       
    SELECT MAX(EVENT_NO) INTO SEQ FROM EVENT;
    
    EXECUTE IMMEDIATE 'CREATE SEQUENCE EVENT_SEQ
                       START WITH ' || SEQ ||
                       ' INCREMENT BY 1';
                       
    SELECT MAX(SPORT_TEAM_NO) INTO SEQ FROM SPORT_TEAM;
    
    EXECUTE IMMEDIATE 'CREATE SEQUENCE SPORT_TEAM_SEQ
                       START WITH ' || SEQ ||
                       ' INCREMENT BY 1';
                       
    SELECT MAX(SPORT_NO) INTO SEQ FROM SPORT;
    
    EXECUTE IMMEDIATE 'CREATE SEQUENCE SPORT_SEQ
                       START WITH ' || SEQ ||
                       ' INCREMENT BY 1';   
END;
/

COMMIT;