-- Drop database if it existed previously
DROP DATABASE IF EXISTS FoodDeliveryDB;

-- Create the database
CREATE DATABASE IF NOT EXISTS FoodDeliveryDB;

-- Use the newly created database
USE FoodDeliveryDB;

-- Create Customer table
CREATE TABLE IF NOT EXISTS Customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(60) NOT NULL,
    phone VARCHAR(9) NOT NULL,
    address TEXT NOT NULL,
    updated_at DATETIME
);

-- Create Restaurant table
CREATE TABLE IF NOT EXISTS Restaurant (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(9) NOT NULL
);

-- Create MenuItem table
CREATE TABLE IF NOT EXISTS MenuItem (
    id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(id)
);

-- Create Order table (we need to add backticks because 'Order' is a reserved keyword)
CREATE TABLE IF NOT EXISTS `Order` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    status ENUM('Pending', 'Delivered') NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(id),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(id)
);

-- Create OrderItem table
CREATE TABLE IF NOT EXISTS OrderItem (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(id),
    FOREIGN KEY (item_id) REFERENCES MenuItem(id)
);

-- Create DeliveryPerson table
CREATE TABLE IF NOT EXISTS DeliveryPerson (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(9) NOT NULL,
    vehicle_plate VARCHAR(8) NOT NULL,
    country VARCHAR(56) NOT NULL
);

-- Create Review table
CREATE TABLE IF NOT EXISTS Review (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    FOREIGN KEY (order_id) REFERENCES `Order`(id)
);

-- Create Delivery table
CREATE TABLE IF NOT EXISTS Delivery (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    delivery_person_id INT NOT NULL,
    status ENUM('In Progress', 'Completed') NOT NULL,
    address TEXT NOT NULL,
    delivery_date DATETIME NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(id),
    FOREIGN KEY (delivery_person_id) REFERENCES DeliveryPerson(id)
);

-- Create Coupon table
CREATE TABLE IF NOT EXISTS Coupon (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(9) NOT NULL,
    discount DECIMAL(10, 2) NOT NULL,
    expiry_date DATETIME NOT NULL
);

-- Create PaymentTransaction table
CREATE TABLE IF NOT EXISTS PaymentTransaction (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    coupon_id INT,
    payment_date DATETIME NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    method ENUM('Card', 'Cash', 'PayPal') NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(id),
    FOREIGN KEY (coupon_id) REFERENCES Coupon(id)
);

-- Create Log table
CREATE TABLE IF NOT EXISTS Log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    log_timestamp DATETIME NOT NULL,
    description TEXT
);


-- Trigger 1
-- Create a trigger to update the "updated_at" column in the Customer table
DELIMITER //
CREATE TRIGGER UpdateCustomerUpdatedAt
BEFORE UPDATE ON Customer
FOR EACH ROW
BEGIN
    -- Set the "updated_at" column to the current date and time
    SET NEW.updated_at = NOW();
END;
//
DELIMITER ;


-- Trigger 2
-- Create a trigger to log order placements
DELIMITER //
CREATE TRIGGER LogOrderPlacement
AFTER INSERT ON PaymentTransaction
FOR EACH ROW
BEGIN
    -- Insert a log entry with order details
    INSERT INTO Log (log_timestamp, description)
    VALUES (NOW(), CONCAT('Order ', NEW.order_id, ' completed for a total of $', NEW.total));
END;
//
DELIMITER ;

-- Trigger 3
-- Create a trigger to use discounts on payment transactions
DELIMITER //

CREATE TRIGGER ApplyPaymentDiscount
BEFORE INSERT ON PaymentTransaction
FOR EACH ROW
BEGIN
    DECLARE coupon_discount DECIMAL(10,2);
    DECLARE coupon_expiry_date DATETIME;

    -- Check if there is a corresponding coupon
    SELECT discount, expiry_date INTO coupon_discount, coupon_expiry_date
    FROM Coupon
    WHERE id = NEW.coupon_id;

    -- If a coupon is found and the expiry date is not in the past, apply the discount to the total
    IF coupon_discount IS NOT NULL THEN
		IF coupon_expiry_date > NOW() THEN
			SET NEW.total = GREATEST(NEW.total - coupon_discount, 0);
            SET NEW.coupon_id = null;
            
            -- Delete coupon row so it can't be used twice
            DELETE FROM Coupon WHERE id = NEW.coupon_id;
		ELSE
			-- Signal an error for expired coupons
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Error: Coupon is expired.';
		END IF;
    END IF;
END;
//

DELIMITER ;

-- Use the newly created database
USE FoodDeliveryDB;

insert into Customer (name, email, phone, address) values ('Carlina Bloodworth', 'cbloodworth0@theatlantic.com', 980111703, '356 Thompson Circle');
insert into Customer (name, email, phone, address) values ('Romeo Dumberell', 'rdumberell1@myspace.com', 934316423, '06864 Canary Avenue');
insert into Customer (name, email, phone, address) values ('Timothea Galiero', 'tgaliero2@aol.com', 900561122, '112 Graceland Parkway');
insert into Customer (name, email, phone, address) values ('Cassie Mac Geaney', 'cmac3@go.com', 916254471, '89050 Thierer Alley');
insert into Customer (name, email, phone, address) values ('Shaine Mayman', 'smayman4@google.pl', 972793904, '7747 Eastwood Place');
insert into Customer (name, email, phone, address) values ('Adah Smeal', 'asmeal5@skyrock.com', 949516918, '3 Eastlawn Lane');
insert into Customer (name, email, phone, address) values ('Sigismondo Patillo', 'spatillo6@digg.com', 932287461, '0921 Delaware Place');
insert into Customer (name, email, phone, address) values ('Thurstan Kedward', 'tkedward7@fema.gov', 962327908, '31 Esker Point');
insert into Customer (name, email, phone, address) values ('Claude MacCaughey', 'cmaccaughey8@purevolume.com', 958933794, '6 Hanson Terrace');
insert into Customer (name, email, phone, address) values ('Tiffani Cattlow', 'tcattlow9@dropbox.com', 925987609, '04711 Dapin Court');
insert into Customer (name, email, phone, address) values ('Yetta Canland', 'ycanlanda@elpais.com', 908838602, '4750 Cambridge Avenue');
insert into Customer (name, email, phone, address) values ('Deidre Prendiville', 'dprendivilleb@constantcontact.com', 940582790, '0 Burning Wood Drive');
insert into Customer (name, email, phone, address) values ('Duffie O''Donoghue', 'dodonoghuec@etsy.com', 982496929, '057 Hauk Circle');
insert into Customer (name, email, phone, address) values ('Cordelia Cheshire', 'ccheshired@ycombinator.com', 950473471, '17 Westerfield Plaza');
insert into Customer (name, email, phone, address) values ('Matias Streeter', 'mstreetere@addtoany.com', 958033801, '0269 Debra Place');
insert into Customer (name, email, phone, address) values ('Toiboid Poundsford', 'tpoundsfordf@businesswire.com', 957675300, '101 Heath Alley');
insert into Customer (name, email, phone, address) values ('Nessy Gilpillan', 'ngilpillang@craigslist.org', 960471255, '2363 5th Court');
insert into Customer (name, email, phone, address) values ('Cass Sowerby', 'csowerbyh@bluehost.com', 938042734, '9 Ridgeway Place');
insert into Customer (name, email, phone, address) values ('Yvonne Beedham', 'ybeedhami@kickstarter.com', 929708615, '26 Huxley Parkway');
insert into Customer (name, email, phone, address) values ('Rickey Semaine', 'rsemainej@eepurl.com', 915072187, '80767 Lukken Street');
insert into Customer (name, email, phone, address) values ('Cullan Matches', 'cmatchesk@shinystat.com', 917507707, '058 Meadow Vale Street');
insert into Customer (name, email, phone, address) values ('Barnabas Lafay', 'blafayl@dmoz.org', 902091717, '0 Summerview Hill');
insert into Customer (name, email, phone, address) values ('Gayelord Scotchmor', 'gscotchmorm@woothemes.com', 937877624, '31931 2nd Pass');
insert into Customer (name, email, phone, address) values ('Falkner Wyer', 'fwyern@google.pl', 949906115, '7977 Texas Terrace');
insert into Customer (name, email, phone, address) values ('Hubert Bentje', 'hbentjeo@msu.edu', 988506965, '729 Roth Junction');
insert into Customer (name, email, phone, address) values ('Drusie Elt', 'deltp@auda.org.au', 993632669, '0896 Sachtjen Terrace');
insert into Customer (name, email, phone, address) values ('Irena Grieves', 'igrievesq@elpais.com', 999345274, '495 Milwaukee Court');
insert into Customer (name, email, phone, address) values ('Venita Pughsley', 'vpughsleyr@independent.co.uk', 994712606, '048 Waxwing Avenue');
insert into Customer (name, email, phone, address) values ('Hyacinthe Menico', 'hmenicos@about.me', 939212516, '5375 Bartelt Parkway');
insert into Customer (name, email, phone, address) values ('Dyanne Rame', 'dramet@auda.org.au', 908617203, '4 Calypso Terrace');
insert into Customer (name, email, phone, address) values ('Hastings Pleat', 'hpleatu@pen.io', 978539760, '142 School Junction');
insert into Customer (name, email, phone, address) values ('Cly Furmage', 'cfurmagev@techcrunch.com', 985119416, '0 Ridgeview Way');
insert into Customer (name, email, phone, address) values ('Page Sterman', 'pstermanw@dot.gov', 979850678, '01292 Little Fleur Lane');
insert into Customer (name, email, phone, address) values ('Denise Clampin', 'dclampinx@ovh.net', 949260827, '7 Declaration Way');
insert into Customer (name, email, phone, address) values ('Kyla Glanz', 'kglanzy@jiathis.com', 946405193, '2789 Hermina Crossing');
insert into Customer (name, email, phone, address) values ('Leeann Trazzi', 'ltrazziz@hhs.gov', 961699113, '7 Colorado Crossing');
insert into Customer (name, email, phone, address) values ('Annissa Dunlap', 'adunlap10@accuweather.com', 919474804, '20352 Dayton Street');
insert into Customer (name, email, phone, address) values ('Rennie Katz', 'rkatz11@nbcnews.com', 998784678, '37 Iowa Street');
insert into Customer (name, email, phone, address) values ('Lucias Tourry', 'ltourry12@hexun.com', 985560845, '9503 Mendota Pass');
insert into Customer (name, email, phone, address) values ('Kendell Lackney', 'klackney13@squarespace.com', 991913026, '23 Northland Road');
insert into Customer (name, email, phone, address) values ('Romonda Dash', 'rdash14@disqus.com', 924182788, '13360 Dorton Plaza');
insert into Customer (name, email, phone, address) values ('Malory Mitkin', 'mmitkin15@tripod.com', 980018513, '4232 Namekagon Circle');
insert into Customer (name, email, phone, address) values ('Wylma Staining', 'wstaining16@storify.com', 920609027, '0 Blue Bill Park Pass');
insert into Customer (name, email, phone, address) values ('Arlee Figgs', 'afiggs17@parallels.com', 952671963, '68575 Petterle Center');
insert into Customer (name, email, phone, address) values ('Leeann Albers', 'lalbers18@princeton.edu', 927576476, '2967 Dwight Point');
insert into Customer (name, email, phone, address) values ('Andy Wodeland', 'awodeland19@fotki.com', 942082829, '634 Oakridge Center');
insert into Customer (name, email, phone, address) values ('Andy Andress', 'aandress1a@xing.com', 987021903, '41 Forest Run Parkway');
insert into Customer (name, email, phone, address) values ('Juliann Schankelborg', 'jschankelborg1b@scribd.com', 966625910, '5378 Shasta Drive');
insert into Customer (name, email, phone, address) values ('Terrance Hall-Gough', 'thallgough1c@jugem.jp', 925507029, '9 Hauk Junction');
insert into Customer (name, email, phone, address) values ('Jana Borris', 'jborris1d@narod.ru', 917183029, '7914 Birchwood Circle');
insert into Customer (name, email, phone, address) values ('Carter D''Aeth', 'cdaeth1e@sohu.com', 926921570, '300 Almo Plaza');
insert into Customer (name, email, phone, address) values ('Marcus Giveen', 'mgiveen1f@seesaa.net', 929585838, '397 Lake View Alley');
insert into Customer (name, email, phone, address) values ('Riki Gillmor', 'rgillmor1g@msn.com', 996596744, '2 Westridge Park');
insert into Customer (name, email, phone, address) values ('Clarey Neate', 'cneate1h@forbes.com', 971743495, '62030 Moulton Drive');
insert into Customer (name, email, phone, address) values ('Conchita Lytle', 'clytle1i@sfgate.com', 952209884, '39 Raven Lane');
insert into Customer (name, email, phone, address) values ('Ashby Brandli', 'abrandli1j@ycombinator.com', 951386148, '8306 Portage Terrace');
insert into Customer (name, email, phone, address) values ('Brooke Hatwells', 'bhatwells1k@technorati.com', 943060284, '7 Cottonwood Road');
insert into Customer (name, email, phone, address) values ('Brendin Dawby', 'bdawby1l@com.com', 962527370, '837 Arkansas Lane');
insert into Customer (name, email, phone, address) values ('Wilma Schrei', 'wschrei1m@stanford.edu', 931814405, '8631 Milwaukee Terrace');
insert into Customer (name, email, phone, address) values ('Beauregard Yesichev', 'byesichev1n@prnewswire.com', 960952909, '8 Dryden Plaza');
insert into Customer (name, email, phone, address) values ('Freddi Larby', 'flarby1o@businessweek.com', 913472692, '323 Dayton Avenue');
insert into Customer (name, email, phone, address) values ('Francklyn Measey', 'fmeasey1p@usatoday.com', 938938076, '0258 Weeping Birch Crossing');
insert into Customer (name, email, phone, address) values ('Gustie Reiach', 'greiach1q@printfriendly.com', 925499476, '706 Harbort Street');
insert into Customer (name, email, phone, address) values ('Katya Eustes', 'keustes1r@histats.com', 900930172, '69 Toban Pass');
insert into Customer (name, email, phone, address) values ('Rosalinda Isley', 'risley1s@cbsnews.com', 980353050, '7977 Vahlen Junction');
insert into Customer (name, email, phone, address) values ('Flory Digges', 'fdigges1t@nbcnews.com', 946526700, '3848 Garrison Park');
insert into Customer (name, email, phone, address) values ('Iorgo McCartan', 'imccartan1u@google.pl', 961055567, '544 Jay Pass');
insert into Customer (name, email, phone, address) values ('Rolf Lucius', 'rlucius1v@bluehost.com', 977863740, '36442 Gina Avenue');
insert into Customer (name, email, phone, address) values ('Monro Bonifazio', 'mbonifazio1w@businesswire.com', 910371940, '188 School Place');
insert into Customer (name, email, phone, address) values ('Mohandis Befroy', 'mbefroy1x@oakley.com', 954479352, '3 Cambridge Way');
insert into Customer (name, email, phone, address) values ('Fleur Kitchen', 'fkitchen1y@dion.ne.jp', 981687448, '42165 Basil Point');
insert into Customer (name, email, phone, address) values ('Grace Sorey', 'gsorey1z@printfriendly.com', 918302272, '661 Bartelt Street');
insert into Customer (name, email, phone, address) values ('Franz Lingwood', 'flingwood20@boston.com', 994993690, '8701 Clarendon Alley');
insert into Customer (name, email, phone, address) values ('Erwin Delyth', 'edelyth21@hostgator.com', 917660782, '93 Shasta Trail');
insert into Customer (name, email, phone, address) values ('Therine Chirm', 'tchirm22@domainmarket.com', 934521004, '10546 Chinook Center');
insert into Customer (name, email, phone, address) values ('Wilden Tillett', 'wtillett23@apache.org', 961259259, '573 Pleasure Drive');
insert into Customer (name, email, phone, address) values ('Maisey Kitteman', 'mkitteman24@devhub.com', 959459278, '9 Fairview Street');
insert into Customer (name, email, phone, address) values ('Kirk Kemme', 'kkemme25@webeden.co.uk', 976694871, '3 Everett Street');
insert into Customer (name, email, phone, address) values ('Kristine Rennie', 'krennie26@mediafire.com', 964454792, '4 Loeprich Court');
insert into Customer (name, email, phone, address) values ('Lillian Keesman', 'lkeesman27@odnoklassniki.ru', 916682678, '7177 5th Parkway');
insert into Customer (name, email, phone, address) values ('Hettie Wiggam', 'hwiggam28@360.cn', 967064904, '2 Elmside Road');
insert into Customer (name, email, phone, address) values ('Linnea Doret', 'ldoret29@odnoklassniki.ru', 949817323, '19 Buhler Road');
insert into Customer (name, email, phone, address) values ('Heinrick Gonzalo', 'hgonzalo2a@amazon.de', 922272469, '51 Katie Road');
insert into Customer (name, email, phone, address) values ('Boycey Spence', 'bspence2b@livejournal.com', 907469144, '3860 Hanover Center');
insert into Customer (name, email, phone, address) values ('Shaina Hamblin', 'shamblin2c@163.com', 907698229, '49 Roxbury Parkway');
insert into Customer (name, email, phone, address) values ('Lyle Matej', 'lmatej2d@infoseek.co.jp', 910166298, '83 Mesta Lane');
insert into Customer (name, email, phone, address) values ('Brion Woolley', 'bwoolley2e@dedecms.com', 913570116, '60772 Parkside Alley');
insert into Customer (name, email, phone, address) values ('Nomi Trigwell', 'ntrigwell2f@acquirethisname.com', 922871599, '802 Thackeray Place');
insert into Customer (name, email, phone, address) values ('Astrix Wixey', 'awixey2g@altervista.org', 977178276, '9271 8th Avenue');
insert into Customer (name, email, phone, address) values ('Lisette Getch', 'lgetch2h@apple.com', 913637164, '034 Susan Junction');
insert into Customer (name, email, phone, address) values ('Verile Durrington', 'vdurrington2i@shinystat.com', 987335183, '29 Killdeer Circle');
insert into Customer (name, email, phone, address) values ('Casie Malitrott', 'cmalitrott2j@booking.com', 955057385, '85 Crest Line Parkway');
insert into Customer (name, email, phone, address) values ('Gerik Songist', 'gsongist2k@instagram.com', 951428644, '152 Schlimgen Road');
insert into Customer (name, email, phone, address) values ('Ernestine Rulton', 'erulton2l@princeton.edu', 999645392, '0296 Heath Avenue');
insert into Customer (name, email, phone, address) values ('Gabbie Domaschke', 'gdomaschke2m@samsung.com', 955995891, '43 Glendale Center');
insert into Customer (name, email, phone, address) values ('Marice Brumbye', 'mbrumbye2n@deviantart.com', 947580598, '22954 Granby Drive');
insert into Customer (name, email, phone, address) values ('Tammy Gabbett', 'tgabbett2o@delicious.com', 917031766, '021 Mesta Alley');
insert into Customer (name, email, phone, address) values ('Lidia Winckles', 'lwinckles2p@dailymotion.com', 965928573, '25614 Cordelia Avenue');
insert into Customer (name, email, phone, address) values ('Suzy Port', 'sport2q@springer.com', 914537665, '611 Mcbride Lane');
insert into Customer (name, email, phone, address) values ('Bertine Pistol', 'bpistol2r@ifeng.com', 940675320, '60 Farwell Road');

insert into Restaurant (name, address, phone) values ('Skajo', '64056 Walton Circle', 985067550);
insert into Restaurant (name, address, phone) values ('Livetube', '91 Coolidge Court', 923237229);
insert into Restaurant (name, address, phone) values ('Brainbox', '9 Orin Park', 967394432);
insert into Restaurant (name, address, phone) values ('Photofeed', '76788 Stang Road', 953481720);
insert into Restaurant (name, address, phone) values ('Nlounge', '424 Bartelt Drive', 973062312);
insert into Restaurant (name, address, phone) values ('Topiczoom', '14 Red Cloud Terrace', 929344140);
insert into Restaurant (name, address, phone) values ('Teklist', '25176 Mcbride Trail', 906734566);
insert into Restaurant (name, address, phone) values ('Dabfeed', '2 Schmedeman Center', 990324816);
insert into Restaurant (name, address, phone) values ('Youopia', '40765 Heffernan Plaza', 968108234);
insert into Restaurant (name, address, phone) values ('Meezzy', '45686 Karstens Way', 939872039);
insert into Restaurant (name, address, phone) values ('Jamia', '06216 Lerdahl Court', 908971344);
insert into Restaurant (name, address, phone) values ('Shufflebeat', '7 Grayhawk Place', 993378454);
insert into Restaurant (name, address, phone) values ('Topicware', '30690 Valley Edge Park', 978921945);
insert into Restaurant (name, address, phone) values ('Photolist', '40 Hansons Plaza', 928724017);
insert into Restaurant (name, address, phone) values ('Dabfeed', '64 Grim Court', 928702828);
insert into Restaurant (name, address, phone) values ('Nlounge', '437 David Circle', 999398606);
insert into Restaurant (name, address, phone) values ('Dynava', '97 Prairie Rose Lane', 904115206);
insert into Restaurant (name, address, phone) values ('Chatterpoint', '9831 Luster Place', 982640715);
insert into Restaurant (name, address, phone) values ('Yata', '6981 Walton Parkway', 942050322);
insert into Restaurant (name, address, phone) values ('Voonyx', '0337 Lawn Road', 984226697);
insert into Restaurant (name, address, phone) values ('Gigashots', '70 Truax Junction', 975145893);
insert into Restaurant (name, address, phone) values ('Feedbug', '38361 Dexter Court', 997517579);
insert into Restaurant (name, address, phone) values ('Katz', '61605 Arkansas Street', 951822394);
insert into Restaurant (name, address, phone) values ('Rhycero', '9192 Stoughton Pass', 930200492);
insert into Restaurant (name, address, phone) values ('Mydeo', '6833 Chinook Plaza', 998253562);
insert into Restaurant (name, address, phone) values ('Voolia', '946 Lawn Street', 997946836);
insert into Restaurant (name, address, phone) values ('Kayveo', '42 Riverside Trail', 953703794);
insert into Restaurant (name, address, phone) values ('Tekfly', '805 Buhler Center', 985145741);
insert into Restaurant (name, address, phone) values ('Fadeo', '01956 Forest Run Center', 964515000);
insert into Restaurant (name, address, phone) values ('Twitterworks', '23192 American Ash Circle', 900172127);
insert into Restaurant (name, address, phone) values ('Abatz', '32 Mifflin Park', 917241454);
insert into Restaurant (name, address, phone) values ('Jaxworks', '0918 Portage Center', 970804974);
insert into Restaurant (name, address, phone) values ('Yakidoo', '90546 Bobwhite Alley', 909218671);
insert into Restaurant (name, address, phone) values ('Edgewire', '866 Sycamore Crossing', 960225033);
insert into Restaurant (name, address, phone) values ('Rhyzio', '1 Nobel Circle', 988836123);
insert into Restaurant (name, address, phone) values ('Livepath', '95183 Ridgeway Road', 982342652);
insert into Restaurant (name, address, phone) values ('Yambee', '1 Grover Center', 904648220);
insert into Restaurant (name, address, phone) values ('Jaxworks', '0409 Golf Course Alley', 913447759);
insert into Restaurant (name, address, phone) values ('Yodo', '362 Sloan Trail', 904863706);
insert into Restaurant (name, address, phone) values ('Dabtype', '1 Charing Cross Plaza', 957640347);
insert into Restaurant (name, address, phone) values ('Realfire', '74 Charing Cross Junction', 933109697);
insert into Restaurant (name, address, phone) values ('Skimia', '9387 Westerfield Circle', 915709494);
insert into Restaurant (name, address, phone) values ('Innojam', '40050 Gale Point', 985663393);
insert into Restaurant (name, address, phone) values ('Linktype', '19 Nobel Street', 963865892);
insert into Restaurant (name, address, phone) values ('Youfeed', '13 Carpenter Circle', 989093183);
insert into Restaurant (name, address, phone) values ('Camido', '268 Mifflin Park', 974661781);
insert into Restaurant (name, address, phone) values ('Youfeed', '7934 Riverside Avenue', 944351661);
insert into Restaurant (name, address, phone) values ('Oyope', '05721 Hansons Trail', 952562902);
insert into Restaurant (name, address, phone) values ('Devify', '68382 Helena Plaza', 993438587);
insert into Restaurant (name, address, phone) values ('Midel', '9345 Monica Plaza', 906199283);
insert into Restaurant (name, address, phone) values ('Browsetype', '70799 Lerdahl Plaza', 991798044);
insert into Restaurant (name, address, phone) values ('Blogpad', '3117 8th Plaza', 942662995);
insert into Restaurant (name, address, phone) values ('Photojam', '9 Sommers Avenue', 939916172);
insert into Restaurant (name, address, phone) values ('Skiba', '62 Riverside Junction', 963757818);
insert into Restaurant (name, address, phone) values ('Pixonyx', '72 Ludington Street', 967656935);
insert into Restaurant (name, address, phone) values ('Kazio', '0 Mallory Alley', 985824511);
insert into Restaurant (name, address, phone) values ('Skinte', '4233 Oak Valley Junction', 923440898);
insert into Restaurant (name, address, phone) values ('Topdrive', '18 Bashford Way', 966992429);
insert into Restaurant (name, address, phone) values ('Cogidoo', '99488 American Alley', 974861717);
insert into Restaurant (name, address, phone) values ('Camido', '44 Mayer Terrace', 903691921);
insert into Restaurant (name, address, phone) values ('Dabvine', '5 Bowman Way', 997844040);
insert into Restaurant (name, address, phone) values ('Brainlounge', '7 Pearson Trail', 959711036);
insert into Restaurant (name, address, phone) values ('Yodoo', '038 Kropf Avenue', 920061166);
insert into Restaurant (name, address, phone) values ('Twinte', '2 Dryden Avenue', 946162510);
insert into Restaurant (name, address, phone) values ('Plambee', '338 Carey Court', 972539949);
insert into Restaurant (name, address, phone) values ('Yotz', '2 Hazelcrest Avenue', 932597810);
insert into Restaurant (name, address, phone) values ('Vimbo', '4 Dorton Pass', 978212089);
insert into Restaurant (name, address, phone) values ('Jaxspan', '42043 Marcy Drive', 965464095);
insert into Restaurant (name, address, phone) values ('Realmix', '789 Warrior Crossing', 958719649);
insert into Restaurant (name, address, phone) values ('Kazu', '175 Bluejay Court', 921741650);
insert into Restaurant (name, address, phone) values ('Tagtune', '6 Pawling Alley', 939487332);
insert into Restaurant (name, address, phone) values ('Fanoodle', '1891 Eggendart Place', 927997395);
insert into Restaurant (name, address, phone) values ('Realcube', '941 Di Loreto Circle', 975643073);
insert into Restaurant (name, address, phone) values ('Mynte', '1 Continental Lane', 912400967);
insert into Restaurant (name, address, phone) values ('Lazzy', '3203 Katie Court', 955837023);
insert into Restaurant (name, address, phone) values ('Kazu', '8 Menomonie Street', 932760551);
insert into Restaurant (name, address, phone) values ('Bubblemix', '152 Scoville Avenue', 976170231);
insert into Restaurant (name, address, phone) values ('Gabvine', '167 Boyd Junction', 971487079);
insert into Restaurant (name, address, phone) values ('Kwinu', '40 Del Sol Hill', 914835194);
insert into Restaurant (name, address, phone) values ('Jetwire', '36 Cherokee Pass', 906101532);
insert into Restaurant (name, address, phone) values ('Digitube', '36493 Superior Junction', 936914920);
insert into Restaurant (name, address, phone) values ('Wordtune', '736 West Road', 999349227);
insert into Restaurant (name, address, phone) values ('Plajo', '5153 Emmet Trail', 975467312);
insert into Restaurant (name, address, phone) values ('Bubblemix', '99 Hovde Circle', 952961725);
insert into Restaurant (name, address, phone) values ('Mymm', '508 Briar Crest Alley', 927227019);
insert into Restaurant (name, address, phone) values ('Photobean', '8 Waywood Junction', 945135593);
insert into Restaurant (name, address, phone) values ('Feedbug', '89236 Marcy Center', 972953089);
insert into Restaurant (name, address, phone) values ('Feednation', '4 Service Place', 907277136);
insert into Restaurant (name, address, phone) values ('Mydeo', '72920 Oakridge Road', 985638489);
insert into Restaurant (name, address, phone) values ('Kanoodle', '68627 Cambridge Terrace', 921436936);
insert into Restaurant (name, address, phone) values ('Oyonder', '19 Roth Avenue', 955840866);
insert into Restaurant (name, address, phone) values ('Jetwire', '4221 Columbus Street', 941769861);
insert into Restaurant (name, address, phone) values ('Roomm', '708 Clyde Gallagher Alley', 948021104);
insert into Restaurant (name, address, phone) values ('Zoonder', '493 Darwin Junction', 919401659);
insert into Restaurant (name, address, phone) values ('InnoZ', '729 Arrowood Hill', 941980964);
insert into Restaurant (name, address, phone) values ('Eadel', '61 Sugar Plaza', 949834989);
insert into Restaurant (name, address, phone) values ('Skaboo', '553 Thompson Road', 992576696);
insert into Restaurant (name, address, phone) values ('Youspan', '30494 Everett Street', 945568938);
insert into Restaurant (name, address, phone) values ('Skaboo', '4 Grasskamp Park', 908282039);
insert into Restaurant (name, address, phone) values ('Voonix', '1424 Almo Circle', 983795346);

insert into MenuItem (restaurant_id, name, description, price) values (92, 'Cheese - Camembert', 'imported', 18.03);
insert into MenuItem (restaurant_id, name, description, price) values (32, 'Muffin Mix - Oatmeal', 'gluten free', 1.15);
insert into MenuItem (restaurant_id, name, description, price) values (45, 'Potato - Sweet', 'gluten free', 9.42);
insert into MenuItem (restaurant_id, name, description, price) values (70, 'Cheese - Pont Couvert', 'imported', 19.21);
insert into MenuItem (restaurant_id, name, description, price) values (73, 'Scotch - Queen Anne', 'imported', 7.44);
insert into MenuItem (restaurant_id, name, description, price) values (11, 'Ostrich - Prime Cut', 'spicy', 1.77);
insert into MenuItem (restaurant_id, name, description, price) values (75, 'Sping Loaded Cup Dispenser', 'vegetarian', 2.29);
insert into MenuItem (restaurant_id, name, description, price) values (23, 'Beans - Wax', 'vegetarian', 14.01);
insert into MenuItem (restaurant_id, name, description, price) values (63, 'Squash - Guords', 'spicy', 19.01);
insert into MenuItem (restaurant_id, name, description, price) values (11, 'Chivas Regal - 12 Year Old', 'no lactose', 16.73);
insert into MenuItem (restaurant_id, name, description, price) values (5, 'Squid - U 5', 'gluten free', 19.58);
insert into MenuItem (restaurant_id, name, description, price) values (28, 'Pail - 15l White, With Handle', 'spicy', 6.14);
insert into MenuItem (restaurant_id, name, description, price) values (25, 'Chicken - White Meat With Tender', 'gluten free', 4.31);
insert into MenuItem (restaurant_id, name, description, price) values (51, 'Salmon - Smoked, Sliced', 'imported', 24.22);
insert into MenuItem (restaurant_id, name, description, price) values (60, 'Cookie Dough - Double', 'gluten free', 16.88);
insert into MenuItem (restaurant_id, name, description, price) values (62, 'Veal - Ground', 'gluten free', 14.17);
insert into MenuItem (restaurant_id, name, description, price) values (92, 'Jerusalem Artichoke', 'gluten free', 8.5);
insert into MenuItem (restaurant_id, name, description, price) values (22, 'Pork - Hock And Feet Attached', 'spicy', 5.97);
insert into MenuItem (restaurant_id, name, description, price) values (49, 'Onion - Dried', 'spicy', 2.46);
insert into MenuItem (restaurant_id, name, description, price) values (74, 'Cake - Sheet Strawberry', 'no lactose', 7.41);
insert into MenuItem (restaurant_id, name, description, price) values (41, 'Flour - Masa De Harina Mexican', 'imported', 23.45);
insert into MenuItem (restaurant_id, name, description, price) values (22, 'Flour - Buckwheat, Dark', 'imported', 13.85);
insert into MenuItem (restaurant_id, name, description, price) values (61, 'Bread - English Muffin', 'no lactose', 1.9);
insert into MenuItem (restaurant_id, name, description, price) values (84, 'Cheese - Brie', 'spicy', 22.13);
insert into MenuItem (restaurant_id, name, description, price) values (48, 'Juice - Lagoon Mango', 'gluten free', 12.25);
insert into MenuItem (restaurant_id, name, description, price) values (28, 'Frangelico', 'gluten free', 16.0);
insert into MenuItem (restaurant_id, name, description, price) values (54, 'Cinnamon - Stick', 'imported', 9.45);
insert into MenuItem (restaurant_id, name, description, price) values (7, 'Island Oasis - Cappucino Mix', 'vegetarian', 18.22);
insert into MenuItem (restaurant_id, name, description, price) values (22, 'Clam - Cherrystone', 'spicy', 17.61);
insert into MenuItem (restaurant_id, name, description, price) values (64, 'Papayas', 'vegetarian', 24.18);
insert into MenuItem (restaurant_id, name, description, price) values (58, 'Foil - Round Foil', 'gluten free', 10.53);
insert into MenuItem (restaurant_id, name, description, price) values (56, 'Soup - Campbells, Lentil', 'spicy', 11.5);
insert into MenuItem (restaurant_id, name, description, price) values (23, 'Wakami Seaweed', 'imported', 11.09);
insert into MenuItem (restaurant_id, name, description, price) values (61, 'Sauce - Rosee', 'imported', 9.73);
insert into MenuItem (restaurant_id, name, description, price) values (65, 'Corn - On The Cob', 'gluten free', 24.58);
insert into MenuItem (restaurant_id, name, description, price) values (85, 'Appetizer - Seafood Assortment', 'imported', 5.15);
insert into MenuItem (restaurant_id, name, description, price) values (5, 'Pastry - Choclate Baked', 'spicy', 21.7);
insert into MenuItem (restaurant_id, name, description, price) values (87, 'Grenadine', 'gluten free', 22.86);
insert into MenuItem (restaurant_id, name, description, price) values (15, 'Extract - Rum', 'gluten free', 10.42);
insert into MenuItem (restaurant_id, name, description, price) values (11, 'Compound - Pear', 'vegetarian', 23.92);
insert into MenuItem (restaurant_id, name, description, price) values (18, 'Rye Special Old', 'vegetarian', 7.02);
insert into MenuItem (restaurant_id, name, description, price) values (12, 'Zucchini - Mini, Green', 'imported', 3.79);
insert into MenuItem (restaurant_id, name, description, price) values (15, 'Syrup - Monin - Passion Fruit', 'imported', 21.74);
insert into MenuItem (restaurant_id, name, description, price) values (48, 'Wine - Periguita Fonseca', 'gluten free', 11.25);
insert into MenuItem (restaurant_id, name, description, price) values (12, 'Swordfish Loin Portions', 'gluten free', 4.84);
insert into MenuItem (restaurant_id, name, description, price) values (41, 'Veal - Shank, Pieces', 'gluten free', 16.81);
insert into MenuItem (restaurant_id, name, description, price) values (92, 'Nantuket Peach Orange', 'spicy', 6.27);
insert into MenuItem (restaurant_id, name, description, price) values (48, 'Higashimaru Usukuchi Soy', 'no lactose', 8.14);
insert into MenuItem (restaurant_id, name, description, price) values (19, 'Vinegar - White', 'no lactose', 3.68);
insert into MenuItem (restaurant_id, name, description, price) values (57, 'Table Cloth 62x120 Colour', 'vegetarian', 23.82);
insert into MenuItem (restaurant_id, name, description, price) values (81, 'Melon - Watermelon Yellow', 'vegetarian', 9.04);
insert into MenuItem (restaurant_id, name, description, price) values (25, 'Olives - Stuffed', 'imported', 20.15);
insert into MenuItem (restaurant_id, name, description, price) values (85, 'Energy Drink', 'gluten free', 1.52);
insert into MenuItem (restaurant_id, name, description, price) values (1, 'Bay Leaf Ground', 'no lactose', 1.97);
insert into MenuItem (restaurant_id, name, description, price) values (36, 'Devonshire Cream', 'gluten free', 7.47);
insert into MenuItem (restaurant_id, name, description, price) values (29, 'Melon - Watermelon, Seedless', 'imported', 5.19);
insert into MenuItem (restaurant_id, name, description, price) values (41, 'Soup - Clam Chowder, Dry Mix', 'imported', 18.27);
insert into MenuItem (restaurant_id, name, description, price) values (8, 'Munchies Honey Sweet Trail Mix', 'imported', 24.99);
insert into MenuItem (restaurant_id, name, description, price) values (89, 'Chickhen - Chicken Phyllo', 'spicy', 6.49);
insert into MenuItem (restaurant_id, name, description, price) values (12, 'Pork - Chop, Frenched', 'spicy', 21.7);
insert into MenuItem (restaurant_id, name, description, price) values (41, 'Beets - Mini Golden', 'spicy', 24.23);
insert into MenuItem (restaurant_id, name, description, price) values (14, 'Veal - Slab Bacon', 'gluten free', 2.22);
insert into MenuItem (restaurant_id, name, description, price) values (4, 'Bread - Corn Muffaletta', 'no lactose', 17.71);
insert into MenuItem (restaurant_id, name, description, price) values (53, 'Bagel - Plain', 'gluten free', 6.39);
insert into MenuItem (restaurant_id, name, description, price) values (78, 'Pasta - Linguini, Dry', 'vegetarian', 6.84);
insert into MenuItem (restaurant_id, name, description, price) values (93, 'Quail - Jumbo Boneless', 'vegetarian', 15.41);
insert into MenuItem (restaurant_id, name, description, price) values (56, 'Cheese - Taleggio D.o.p.', 'gluten free', 11.11);
insert into MenuItem (restaurant_id, name, description, price) values (36, 'Soup - Campbells Chicken', 'vegetarian', 2.05);
insert into MenuItem (restaurant_id, name, description, price) values (25, 'Cabbage Roll', 'no lactose', 22.63);
insert into MenuItem (restaurant_id, name, description, price) values (2, 'Lemon Balm - Fresh', 'vegetarian', 18.93);
insert into MenuItem (restaurant_id, name, description, price) values (46, 'Olives - Kalamata', 'spicy', 10.0);
insert into MenuItem (restaurant_id, name, description, price) values (37, 'Bag - Regular Kraft 20 Lb', 'no lactose', 16.11);
insert into MenuItem (restaurant_id, name, description, price) values (90, 'Nut - Hazelnut, Whole', 'no lactose', 21.39);
insert into MenuItem (restaurant_id, name, description, price) values (7, 'Soup - Knorr, Chicken Gumbo', 'spicy', 15.18);
insert into MenuItem (restaurant_id, name, description, price) values (22, 'Papayas', 'vegetarian', 22.51);
insert into MenuItem (restaurant_id, name, description, price) values (50, 'Dehydrated Kelp Kombo', 'imported', 16.91);
insert into MenuItem (restaurant_id, name, description, price) values (46, 'Vodka - Smirnoff', 'spicy', 2.28);
insert into MenuItem (restaurant_id, name, description, price) values (40, 'Sauce - Vodka Blush', 'gluten free', 3.36);
insert into MenuItem (restaurant_id, name, description, price) values (83, 'Orange - Blood', 'imported', 6.57);
insert into MenuItem (restaurant_id, name, description, price) values (44, 'Skirt - 24 Foot', 'imported', 17.38);
insert into MenuItem (restaurant_id, name, description, price) values (43, 'Lamb - Shoulder, Boneless', 'vegetarian', 10.74);
insert into MenuItem (restaurant_id, name, description, price) values (71, 'Higashimaru Usukuchi Soy', 'spicy', 18.52);
insert into MenuItem (restaurant_id, name, description, price) values (93, 'Beer - Creemore', 'gluten free', 18.94);
insert into MenuItem (restaurant_id, name, description, price) values (1, 'Cocktail Napkin Blue', 'spicy', 9.69);
insert into MenuItem (restaurant_id, name, description, price) values (55, 'Bagel - Everything Presliced', 'imported', 20.69);
insert into MenuItem (restaurant_id, name, description, price) values (2, 'Latex Rubber Gloves Size 9', 'gluten free', 17.11);
insert into MenuItem (restaurant_id, name, description, price) values (58, 'Nantucket Apple Juice', 'no lactose', 8.71);
insert into MenuItem (restaurant_id, name, description, price) values (68, 'Capon - Whole', 'gluten free', 3.63);
insert into MenuItem (restaurant_id, name, description, price) values (66, 'Rum - Light, Captain Morgan', 'imported', 13.77);
insert into MenuItem (restaurant_id, name, description, price) values (86, 'Tomato - Tricolor Cherry', 'vegetarian', 7.1);
insert into MenuItem (restaurant_id, name, description, price) values (28, 'Wine - Piper Heidsieck Brut', 'spicy', 23.7);
insert into MenuItem (restaurant_id, name, description, price) values (67, 'Sugar - Invert', 'no lactose', 21.03);
insert into MenuItem (restaurant_id, name, description, price) values (97, 'Beef - Rouladin, Sliced', 'imported', 13.72);
insert into MenuItem (restaurant_id, name, description, price) values (69, 'Spinach - Baby', 'spicy', 11.83);
insert into MenuItem (restaurant_id, name, description, price) values (55, 'Cranberry Foccacia', 'no lactose', 2.01);
insert into MenuItem (restaurant_id, name, description, price) values (51, 'Paper Towel Touchless', 'vegetarian', 3.95);
insert into MenuItem (restaurant_id, name, description, price) values (64, 'Wild Boar - Tenderloin', 'vegetarian', 22.82);
insert into MenuItem (restaurant_id, name, description, price) values (53, 'Gingerale - Schweppes, 355 Ml', 'vegetarian', 18.29);
insert into MenuItem (restaurant_id, name, description, price) values (35, 'Cookie Choc', 'gluten free', 16.76);
insert into MenuItem (restaurant_id, name, description, price) values (79, 'Table Cloth 54x72 White', 'imported', 8.74);

insert into `Order` (customer_id, restaurant_id, order_date, status) values (8, 27, '2022-03-23', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (48, 73, '2023-12-09', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (87, 76, '2022-03-13', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (15, 64, '2024-08-14', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (42, 65, '2022-05-10', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (23, 83, '2022-04-02', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (94, 52, '2022-10-16', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (33, 11, '2023-10-26', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (44, 58, '2022-09-19', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (34, 93, '2024-04-23', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (47, 51, '2023-05-19', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (50, 65, '2022-06-18', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (71, 58, '2022-09-26', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (98, 34, '2023-09-08', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (37, 25, '2023-08-06', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (59, 9, '2023-03-03', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (63, 3, '2022-12-13', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (8, 93, '2024-10-09', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (39, 99, '2024-05-09', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (8, 60, '2024-01-30', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (83, 84, '2024-03-15', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (90, 84, '2023-05-21', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (14, 18, '2023-04-05', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (17, 95, '2022-10-25', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (45, 86, '2023-10-31', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (77, 67, '2024-06-21', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (31, 35, '2023-09-26', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (69, 46, '2024-01-20', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (60, 1, '2023-01-11', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (21, 22, '2024-08-20', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (65, 75, '2023-01-06', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (91, 55, '2022-03-03', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (87, 88, '2024-05-22', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (98, 16, '2022-01-02', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (73, 47, '2023-01-02', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (80, 33, '2023-10-04', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (2, 20, '2023-02-08', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (9, 3, '2022-11-21', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (82, 80, '2024-12-31', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (16, 65, '2022-10-11', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (11, 95, '2024-06-26', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (21, 80, '2023-02-12', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (9, 14, '2022-05-08', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (15, 62, '2023-10-03', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (42, 66, '2024-01-15', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (16, 87, '2022-09-14', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (6, 55, '2022-12-13', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (21, 95, '2023-04-05', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (68, 2, '2022-12-21', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (62, 85, '2024-01-02', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (95, 28, '2023-09-15', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (41, 23, '2024-02-18', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (73, 3, '2024-10-12', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (96, 3, '2023-09-14', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (34, 61, '2023-10-21', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (61, 99, '2022-04-13', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (96, 12, '2024-12-23', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (36, 84, '2024-06-29', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (87, 68, '2023-11-17', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (61, 82, '2022-06-04', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (15, 44, '2024-01-28', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (56, 5, '2024-03-26', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (90, 74, '2022-12-11', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (13, 42, '2023-12-30', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (15, 17, '2024-06-25', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (7, 81, '2024-07-22', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (94, 51, '2024-12-07', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (56, 3, '2022-03-11', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (35, 31, '2024-01-17', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (34, 78, '2024-03-27', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (64, 44, '2024-09-20', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (55, 61, '2022-08-01', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (83, 36, '2023-04-15', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (22, 18, '2024-03-07', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (7, 69, '2024-12-20', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (79, 46, '2024-10-08', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (88, 20, '2024-07-25', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (8, 41, '2024-09-30', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (42, 36, '2022-11-21', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (68, 85, '2023-11-03', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (39, 9, '2022-09-04', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (4, 77, '2024-06-12', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (28, 50, '2024-01-02', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (62, 95, '2024-10-19', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (62, 1, '2024-12-06', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (99, 53, '2024-01-01', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (92, 90, '2024-02-11', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (82, 62, '2024-03-04', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (39, 11, '2023-04-03', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (71, 26, '2024-01-02', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (11, 12, '2022-06-01', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (64, 5, '2022-09-05', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (34, 22, '2023-12-31', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (70, 42, '2023-04-22', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (75, 32, '2022-11-16', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (92, 37, '2024-04-22', 'Delivered');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (25, 23, '2023-03-13', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (29, 16, '2023-08-04', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (37, 72, '2024-05-11', 'Pending');
insert into `Order` (customer_id, restaurant_id, order_date, status) values (65, 89, '2023-01-16', 'Delivered');

insert into OrderItem (order_id, item_id, quantity) values (96, 30, 4);
insert into OrderItem (order_id, item_id, quantity) values (6, 52, 5);
insert into OrderItem (order_id, item_id, quantity) values (34, 60, 5);
insert into OrderItem (order_id, item_id, quantity) values (8, 9, 3);
insert into OrderItem (order_id, item_id, quantity) values (73, 5, 2);
insert into OrderItem (order_id, item_id, quantity) values (19, 79, 1);
insert into OrderItem (order_id, item_id, quantity) values (80, 1, 4);
insert into OrderItem (order_id, item_id, quantity) values (31, 82, 4);
insert into OrderItem (order_id, item_id, quantity) values (12, 64, 5);
insert into OrderItem (order_id, item_id, quantity) values (30, 65, 5);
insert into OrderItem (order_id, item_id, quantity) values (48, 89, 2);
insert into OrderItem (order_id, item_id, quantity) values (31, 44, 4);
insert into OrderItem (order_id, item_id, quantity) values (92, 48, 1);
insert into OrderItem (order_id, item_id, quantity) values (67, 32, 4);
insert into OrderItem (order_id, item_id, quantity) values (66, 19, 4);
insert into OrderItem (order_id, item_id, quantity) values (26, 69, 3);
insert into OrderItem (order_id, item_id, quantity) values (29, 79, 5);
insert into OrderItem (order_id, item_id, quantity) values (20, 92, 1);
insert into OrderItem (order_id, item_id, quantity) values (38, 16, 2);
insert into OrderItem (order_id, item_id, quantity) values (28, 98, 1);
insert into OrderItem (order_id, item_id, quantity) values (54, 34, 4);
insert into OrderItem (order_id, item_id, quantity) values (18, 87, 2);
insert into OrderItem (order_id, item_id, quantity) values (35, 9, 2);
insert into OrderItem (order_id, item_id, quantity) values (3, 44, 4);
insert into OrderItem (order_id, item_id, quantity) values (97, 40, 1);
insert into OrderItem (order_id, item_id, quantity) values (43, 25, 1);
insert into OrderItem (order_id, item_id, quantity) values (9, 27, 4);
insert into OrderItem (order_id, item_id, quantity) values (11, 15, 3);
insert into OrderItem (order_id, item_id, quantity) values (80, 83, 3);
insert into OrderItem (order_id, item_id, quantity) values (81, 92, 4);
insert into OrderItem (order_id, item_id, quantity) values (63, 40, 3);
insert into OrderItem (order_id, item_id, quantity) values (1, 95, 4);
insert into OrderItem (order_id, item_id, quantity) values (64, 65, 3);
insert into OrderItem (order_id, item_id, quantity) values (10, 58, 2);
insert into OrderItem (order_id, item_id, quantity) values (74, 23, 5);
insert into OrderItem (order_id, item_id, quantity) values (10, 78, 4);
insert into OrderItem (order_id, item_id, quantity) values (93, 57, 1);
insert into OrderItem (order_id, item_id, quantity) values (12, 65, 4);
insert into OrderItem (order_id, item_id, quantity) values (5, 14, 3);
insert into OrderItem (order_id, item_id, quantity) values (36, 57, 5);
insert into OrderItem (order_id, item_id, quantity) values (87, 38, 4);
insert into OrderItem (order_id, item_id, quantity) values (82, 65, 1);
insert into OrderItem (order_id, item_id, quantity) values (96, 22, 3);
insert into OrderItem (order_id, item_id, quantity) values (19, 52, 1);
insert into OrderItem (order_id, item_id, quantity) values (16, 16, 4);
insert into OrderItem (order_id, item_id, quantity) values (22, 39, 3);
insert into OrderItem (order_id, item_id, quantity) values (65, 88, 1);
insert into OrderItem (order_id, item_id, quantity) values (20, 15, 5);
insert into OrderItem (order_id, item_id, quantity) values (59, 27, 2);
insert into OrderItem (order_id, item_id, quantity) values (33, 31, 4);
insert into OrderItem (order_id, item_id, quantity) values (78, 58, 2);
insert into OrderItem (order_id, item_id, quantity) values (40, 82, 1);
insert into OrderItem (order_id, item_id, quantity) values (74, 72, 4);
insert into OrderItem (order_id, item_id, quantity) values (8, 91, 1);
insert into OrderItem (order_id, item_id, quantity) values (92, 86, 1);
insert into OrderItem (order_id, item_id, quantity) values (30, 10, 4);
insert into OrderItem (order_id, item_id, quantity) values (9, 19, 2);
insert into OrderItem (order_id, item_id, quantity) values (32, 3, 4);
insert into OrderItem (order_id, item_id, quantity) values (83, 8, 5);
insert into OrderItem (order_id, item_id, quantity) values (46, 49, 3);
insert into OrderItem (order_id, item_id, quantity) values (13, 47, 4);
insert into OrderItem (order_id, item_id, quantity) values (45, 74, 1);
insert into OrderItem (order_id, item_id, quantity) values (33, 63, 5);
insert into OrderItem (order_id, item_id, quantity) values (84, 15, 3);
insert into OrderItem (order_id, item_id, quantity) values (18, 41, 2);
insert into OrderItem (order_id, item_id, quantity) values (64, 16, 2);
insert into OrderItem (order_id, item_id, quantity) values (9, 99, 2);
insert into OrderItem (order_id, item_id, quantity) values (16, 32, 5);
insert into OrderItem (order_id, item_id, quantity) values (62, 7, 2);
insert into OrderItem (order_id, item_id, quantity) values (26, 68, 4);
insert into OrderItem (order_id, item_id, quantity) values (73, 38, 2);
insert into OrderItem (order_id, item_id, quantity) values (4, 66, 2);
insert into OrderItem (order_id, item_id, quantity) values (56, 62, 3);
insert into OrderItem (order_id, item_id, quantity) values (93, 34, 2);
insert into OrderItem (order_id, item_id, quantity) values (60, 46, 5);
insert into OrderItem (order_id, item_id, quantity) values (46, 7, 5);
insert into OrderItem (order_id, item_id, quantity) values (55, 30, 3);
insert into OrderItem (order_id, item_id, quantity) values (41, 74, 4);
insert into OrderItem (order_id, item_id, quantity) values (42, 53, 1);
insert into OrderItem (order_id, item_id, quantity) values (32, 56, 3);
insert into OrderItem (order_id, item_id, quantity) values (43, 2, 3);
insert into OrderItem (order_id, item_id, quantity) values (97, 45, 4);
insert into OrderItem (order_id, item_id, quantity) values (71, 4, 5);
insert into OrderItem (order_id, item_id, quantity) values (80, 75, 2);
insert into OrderItem (order_id, item_id, quantity) values (28, 29, 4);
insert into OrderItem (order_id, item_id, quantity) values (9, 53, 5);
insert into OrderItem (order_id, item_id, quantity) values (28, 30, 3);
insert into OrderItem (order_id, item_id, quantity) values (84, 42, 4);
insert into OrderItem (order_id, item_id, quantity) values (26, 42, 5);
insert into OrderItem (order_id, item_id, quantity) values (47, 92, 3);
insert into OrderItem (order_id, item_id, quantity) values (9, 97, 4);
insert into OrderItem (order_id, item_id, quantity) values (9, 43, 1);
insert into OrderItem (order_id, item_id, quantity) values (56, 8, 4);
insert into OrderItem (order_id, item_id, quantity) values (76, 42, 2);
insert into OrderItem (order_id, item_id, quantity) values (68, 19, 5);
insert into OrderItem (order_id, item_id, quantity) values (100, 43, 5);
insert into OrderItem (order_id, item_id, quantity) values (31, 89, 1);
insert into OrderItem (order_id, item_id, quantity) values (93, 32, 1);
insert into OrderItem (order_id, item_id, quantity) values (7, 69, 4);
insert into OrderItem (order_id, item_id, quantity) values (43, 7, 1);

insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Keene Betham', '946352369', 'SH-25-FS', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Noella Hallums', '951136743', 'QR-31-UM', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Jourdain Ranstead', '957598155', 'HO-41-WV', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Bernie Baraclough', '963832000', 'UW-39-VZ', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Clementius Smails', '940590936', 'XD-09-AR', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Hillie Spehr', '971262006', 'RP-31-MA', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Olympie Siehard', '925350400', 'GE-60-NI', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Vince Ferentz', '990034190', 'UB-18-MQ', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Lian Bryenton', '977749730', 'FJ-02-KB', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Yorgo O''Gormley', '901125518', 'RF-23-AB', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Garrett Spira', '978177721', 'PC-27-XO', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Tammi Etock', '916091022', 'FW-91-BL', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Carmina Charters', '906724531', 'NT-95-KF', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Audrie Sjostrom', '938018105', 'EB-12-KG', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Malinde Baylis', '926943368', 'CM-54-MT', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Cammi Woakes', '920981097', 'TR-57-AH', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Fionna Illston', '975009719', 'YP-57-AM', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Layney Emmott', '987904172', 'YW-50-JR', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Willetta Knight', '905994442', 'MU-35-LG', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Vin Searson', '979730610', 'NJ-12-OZ', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Kare Cole', '980111212', 'DK-12-VX', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Sammie Ferraron', '951469615', 'PV-30-BX', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Abelard Dadds', '957636267', 'ZF-20-JU', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Randie Thurley', '946971769', 'XV-27-GN', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Eugene Epgrave', '997476594', 'BP-88-UV', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Emylee Emes', '949578920', 'CF-12-TH', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Vikky Ibbett', '914928518', 'XI-51-LK', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Michaeline Stacey', '923451663', 'UE-02-MD', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Orlando Tschiersch', '987470201', 'DC-87-VO', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Karyn Tulloch', '912217646', 'CV-34-OW', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Langston Naish', '946433890', 'SO-36-LL', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Aleda Garrit', '991687376', 'IB-02-LN', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Sasha Humphris', '912830576', 'PD-16-OF', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Sasha Gladding', '980486742', 'OC-58-IR', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Dorie Ickovits', '942793644', 'VO-47-KB', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Ursulina Vernazza', '968174340', 'NY-03-FF', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Sherwynd Occleshaw', '918999940', 'PI-82-YH', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Haven Marcus', '954983191', 'MD-97-RR', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Toddie Bendan', '951682086', 'PD-41-ZM', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Krispin Millard', '951999664', 'AN-34-NC', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Haskel Daye', '988943998', 'FN-73-XZ', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Chrysa MacCardle', '939211427', 'WD-92-WO', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Lenee Hainge', '986633639', 'PE-96-NJ', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Jervis Halahan', '978412172', 'UF-42-DX', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Jule Stark', '988354093', 'BY-34-XB', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Betty Larrie', '933080191', 'HG-42-VC', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Arv Chinnock', '900058276', 'UP-29-RF', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Cairistiona Ellerby', '986173729', 'VQ-35-YW', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Mose Capon', '927606633', 'CT-87-IJ', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Margarita Pimer', '947122559', 'BS-79-RO', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Townsend McElmurray', '928377317', 'UY-00-DT', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Caz Klug', '964172292', 'VM-69-DK', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Quintus Eilhertsen', '984526102', 'UQ-02-GR', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Konstantin Clifft', '952440872', 'DC-43-BM', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Pancho Reijmers', '902985848', 'XG-37-OU', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Fraze Houlridge', '980577019', 'HO-27-SF', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Cordie Lorentz', '999907383', 'BJ-78-SY', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Jdavie Franz-Schoninger', '913313595', 'ZY-43-TB', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Gardie Macieiczyk', '965100291', 'JA-86-CQ', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Rudyard Amsberger', '960811457', 'SW-29-SN', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Bunny Snowsill', '965833139', 'AH-83-RW', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Rosalinda Boswood', '977512618', 'GV-19-JI', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Montague Dunstone', '933619637', 'LS-84-GY', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Paulo Studart', '962312356', 'GD-71-HN', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Keslie Brolly', '901330630', 'AU-87-MH', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Francois D''Aulby', '936828169', 'KF-71-RC', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Ethel Ellum', '917239893', 'VC-84-US', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Torrance Daouse', '991953892', 'CH-97-KI', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Ev Sigert', '915983612', 'VF-92-XK', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Cherie Georgiev', '966628535', 'BU-54-TC', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Odele Kitcatt', '958469789', 'VJ-32-DT', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Valene Fraanchyonok', '933063100', 'AK-18-YV', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Annmarie Bountiff', '970309577', 'ZU-03-SC', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Annemarie Wiggam', '916705090', 'CC-59-WR', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Edwina Hakewell', '958610378', 'UL-70-QL', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Welbie Auty', '997138972', 'CO-50-JT', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Connor Connochie', '944358835', 'IZ-33-DZ', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Evyn Corinton', '912628652', 'DQ-09-XR', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Lark Sarjeant', '952230986', 'XN-64-CT', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Giuditta Greenham', '993347979', 'BM-57-WB', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Alberto Jaumet', '903396667', 'BQ-29-DV', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Alyda Banthorpe', '948801027', 'DV-18-GH', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Cecily Chaplyn', '999222536', 'IH-58-PV', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Cherri Rodrigo', '998941545', 'TZ-08-MP', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Renate Kryzhov', '937693324', 'TB-68-HO', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Kris Youell', '912621614', 'AI-76-PR', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Irene Tupman', '932374828', 'WK-99-TS', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Codi MacGow', '936266376', 'VG-59-XJ', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Jeremias MacLucais', '952296928', 'JI-55-UW', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Kylie Somerlie', '953592163', 'HW-24-YP', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Denys Derkes', '929693594', 'HZ-68-RF', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Tobiah Searl', '987509502', 'PC-74-LM', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Rowena Selwyne', '992127069', 'TK-09-MF', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Reynold Janczewski', '981012087', 'WE-68-RB', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Iormina Jeckells', '998147378', 'TE-65-TN', 'Braga');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Mattie Grishukov', '967096908', 'BF-06-HK', 'Porto');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Ania Chastand', '911694760', 'CI-29-CQ', 'Algarve');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Liliane Lyffe', '911692418', 'UV-48-IE', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Madalyn Barge', '945768366', 'ZF-51-PZ', 'Lisboa');
insert into DeliveryPerson (name, phone, vehicle_plate, country) values ('Yetty Alwell', '946950570', 'XO-21-TY', 'Lisboa');

insert into Review (order_id, rating, comment) values (72, 5, 'Too noisy');
insert into Review (order_id, rating, comment) values (14, 3, null);
insert into Review (order_id, rating, comment) values (48, 4, 'Amazing service');
insert into Review (order_id, rating, comment) values (67, 4, 'Amazing service');
insert into Review (order_id, rating, comment) values (72, 5, null);
insert into Review (order_id, rating, comment) values (46, 3, 'Too noisy');
insert into Review (order_id, rating, comment) values (24, 5, null);
insert into Review (order_id, rating, comment) values (88, 3, null);
insert into Review (order_id, rating, comment) values (53, 2, 'Food took too long');
insert into Review (order_id, rating, comment) values (64, 5, null);
insert into Review (order_id, rating, comment) values (94, 2, 'Too noisy');
insert into Review (order_id, rating, comment) values (95, 3, null);
insert into Review (order_id, rating, comment) values (74, 3, 'Amazing service');
insert into Review (order_id, rating, comment) values (67, 1, 'Food took too long');
insert into Review (order_id, rating, comment) values (56, 3, 'Too noisy');
insert into Review (order_id, rating, comment) values (45, 2, 'Good food');
insert into Review (order_id, rating, comment) values (76, 4, 'Good food');
insert into Review (order_id, rating, comment) values (9, 3, 'Food took too long');
insert into Review (order_id, rating, comment) values (68, 3, null);
insert into Review (order_id, rating, comment) values (87, 2, null);
insert into Review (order_id, rating, comment) values (44, 5, null);
insert into Review (order_id, rating, comment) values (41, 1, null);
insert into Review (order_id, rating, comment) values (91, 2, null);
insert into Review (order_id, rating, comment) values (95, 2, 'Too noisy');
insert into Review (order_id, rating, comment) values (23, 5, 'Good food');
insert into Review (order_id, rating, comment) values (46, 4, null);
insert into Review (order_id, rating, comment) values (22, 1, null);
insert into Review (order_id, rating, comment) values (68, 1, null);
insert into Review (order_id, rating, comment) values (66, 5, 'Food took too long');
insert into Review (order_id, rating, comment) values (31, 3, null);
insert into Review (order_id, rating, comment) values (91, 1, 'Bad waiter');
insert into Review (order_id, rating, comment) values (86, 5, null);
insert into Review (order_id, rating, comment) values (85, 3, 'Good food');
insert into Review (order_id, rating, comment) values (84, 4, 'Good food');
insert into Review (order_id, rating, comment) values (63, 2, 'Good food');
insert into Review (order_id, rating, comment) values (21, 4, null);
insert into Review (order_id, rating, comment) values (27, 5, null);
insert into Review (order_id, rating, comment) values (39, 2, null);
insert into Review (order_id, rating, comment) values (10, 5, 'Bad waiter');
insert into Review (order_id, rating, comment) values (91, 2, null);
insert into Review (order_id, rating, comment) values (44, 5, null);
insert into Review (order_id, rating, comment) values (83, 3, null);
insert into Review (order_id, rating, comment) values (1, 1, null);
insert into Review (order_id, rating, comment) values (36, 5, 'Too noisy');
insert into Review (order_id, rating, comment) values (45, 2, null);
insert into Review (order_id, rating, comment) values (46, 4, 'Good food');
insert into Review (order_id, rating, comment) values (98, 5, 'Good food');
insert into Review (order_id, rating, comment) values (31, 2, 'Too noisy');
insert into Review (order_id, rating, comment) values (78, 5, 'Good food');
insert into Review (order_id, rating, comment) values (30, 4, null);
insert into Review (order_id, rating, comment) values (59, 3, 'Bad waiter');
insert into Review (order_id, rating, comment) values (10, 5, null);
insert into Review (order_id, rating, comment) values (39, 1, null);
insert into Review (order_id, rating, comment) values (30, 4, 'Good food');
insert into Review (order_id, rating, comment) values (84, 1, null);
insert into Review (order_id, rating, comment) values (87, 5, 'Food took too long');
insert into Review (order_id, rating, comment) values (66, 2, 'Amazing service');
insert into Review (order_id, rating, comment) values (28, 2, 'Good food');
insert into Review (order_id, rating, comment) values (93, 3, 'Good food');
insert into Review (order_id, rating, comment) values (2, 5, null);
insert into Review (order_id, rating, comment) values (38, 1, 'Food took too long');
insert into Review (order_id, rating, comment) values (40, 5, null);
insert into Review (order_id, rating, comment) values (50, 4, 'Bad waiter');
insert into Review (order_id, rating, comment) values (76, 1, null);
insert into Review (order_id, rating, comment) values (35, 4, 'Good food');
insert into Review (order_id, rating, comment) values (68, 2, null);
insert into Review (order_id, rating, comment) values (75, 1, null);
insert into Review (order_id, rating, comment) values (35, 4, 'Amazing service');
insert into Review (order_id, rating, comment) values (70, 3, 'Bad waiter');
insert into Review (order_id, rating, comment) values (38, 1, 'Bad waiter');
insert into Review (order_id, rating, comment) values (24, 5, 'Amazing service');
insert into Review (order_id, rating, comment) values (91, 3, 'Too noisy');
insert into Review (order_id, rating, comment) values (69, 3, null);
insert into Review (order_id, rating, comment) values (92, 2, null);
insert into Review (order_id, rating, comment) values (52, 1, 'Food took too long');
insert into Review (order_id, rating, comment) values (97, 2, 'Too noisy');
insert into Review (order_id, rating, comment) values (80, 4, 'Too noisy');
insert into Review (order_id, rating, comment) values (20, 2, null);
insert into Review (order_id, rating, comment) values (75, 3, 'Bad waiter');
insert into Review (order_id, rating, comment) values (64, 5, 'Bad waiter');
insert into Review (order_id, rating, comment) values (43, 3, 'Amazing service');
insert into Review (order_id, rating, comment) values (68, 5, null);
insert into Review (order_id, rating, comment) values (93, 1, null);
insert into Review (order_id, rating, comment) values (14, 5, null);
insert into Review (order_id, rating, comment) values (89, 5, null);
insert into Review (order_id, rating, comment) values (22, 4, null);
insert into Review (order_id, rating, comment) values (89, 5, null);
insert into Review (order_id, rating, comment) values (64, 4, 'Food took too long');
insert into Review (order_id, rating, comment) values (85, 2, null);
insert into Review (order_id, rating, comment) values (41, 4, null);
insert into Review (order_id, rating, comment) values (4, 4, null);
insert into Review (order_id, rating, comment) values (14, 1, null);
insert into Review (order_id, rating, comment) values (52, 4, null);
insert into Review (order_id, rating, comment) values (100, 5, null);
insert into Review (order_id, rating, comment) values (10, 4, null);
insert into Review (order_id, rating, comment) values (55, 5, 'Food took too long');
insert into Review (order_id, rating, comment) values (59, 3, 'Too noisy');
insert into Review (order_id, rating, comment) values (55, 1, null);
insert into Review (order_id, rating, comment) values (58, 4, 'Good food');
insert into Review (order_id, rating, comment) values (77, 3, 'Amazing service');

insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (19, 76, 'Completed', '44 2nd Park', '2022-08-07');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (49, 73, 'In Progress', '732 6th Terrace', '2022-10-17');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (24, 50, 'In Progress', '47368 Pierstorff Point', '2022-12-24');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (58, 54, 'Completed', '285 Susan Circle', '2023-04-15');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (54, 96, 'In Progress', '6182 Miller Drive', '2023-04-21');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (75, 58, 'In Progress', '7 Acker Park', '2022-12-16');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (8, 97, 'Completed', '00 Dunning Circle', '2023-06-14');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (51, 57, 'Completed', '6870 Sunbrook Pass', '2023-07-06');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (2, 78, 'Completed', '13 Kenwood Hill', '2022-10-11');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (11, 61, 'Completed', '3 Burrows Point', '2022-11-17');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (59, 86, 'In Progress', '4267 School Center', '2023-05-15');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (81, 88, 'In Progress', '9 Twin Pines Avenue', '2022-10-29');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (65, 89, 'In Progress', '062 Ryan Drive', '2023-04-07');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (23, 98, 'In Progress', '5132 Forest Run Lane', '2023-06-24');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (84, 74, 'Completed', '39 Oneill Junction', '2022-09-23');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (6, 15, 'In Progress', '99 Vahlen Trail', '2022-12-04');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (85, 42, 'Completed', '3 Ilene Lane', '2023-04-14');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (26, 22, 'Completed', '98964 Hansons Hill', '2023-03-11');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (10, 16, 'In Progress', '37 Marcy Avenue', '2022-11-28');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (24, 83, 'Completed', '773 Havey Alley', '2022-11-29');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (35, 67, 'In Progress', '58312 Bayside Lane', '2022-10-09');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (25, 18, 'Completed', '13 Hoffman Avenue', '2022-09-16');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (78, 65, 'In Progress', '98 Southridge Parkway', '2023-03-17');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (20, 30, 'Completed', '0448 Badeau Crossing', '2022-10-06');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (42, 41, 'Completed', '518 Almo Parkway', '2022-09-23');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (71, 2, 'In Progress', '81 Sauthoff Crossing', '2023-05-06');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (91, 34, 'Completed', '330 Service Crossing', '2022-10-11');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (68, 98, 'In Progress', '6027 Welch Way', '2022-10-21');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (91, 28, 'Completed', '18561 Lighthouse Bay Center', '2022-09-06');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (18, 73, 'Completed', '03 Bunting Circle', '2022-10-07');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (40, 35, 'In Progress', '4 Delaware Parkway', '2023-02-20');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (80, 74, 'Completed', '6 Cardinal Road', '2022-07-22');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (91, 79, 'In Progress', '610 Tennyson Junction', '2022-11-25');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (5, 71, 'In Progress', '2843 Jay Court', '2022-12-11');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (84, 11, 'In Progress', '092 Clarendon Crossing', '2023-04-05');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (65, 29, 'Completed', '589 Hanson Drive', '2022-12-30');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (27, 64, 'Completed', '83 Talisman Park', '2022-07-17');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (32, 24, 'In Progress', '1129 Muir Street', '2022-10-07');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (14, 68, 'Completed', '3 Ridge Oak Drive', '2022-10-16');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (17, 44, 'In Progress', '95151 Anzinger Way', '2022-09-29');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (85, 18, 'Completed', '6456 Lillian Street', '2023-06-09');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (18, 29, 'Completed', '076 Waubesa Alley', '2023-04-24');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (16, 89, 'Completed', '587 Hazelcrest Place', '2023-01-25');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (86, 90, 'In Progress', '156 Fremont Court', '2022-10-23');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (49, 11, 'In Progress', '443 Dawn Circle', '2022-12-13');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (58, 12, 'In Progress', '917 Lakewood Gardens Way', '2022-11-07');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (28, 19, 'Completed', '26690 Magdeline Park', '2023-01-03');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (83, 46, 'Completed', '831 Charing Cross Circle', '2022-11-08');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (7, 53, 'In Progress', '4544 Pawling Avenue', '2023-01-30');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (61, 84, 'In Progress', '32 5th Plaza', '2022-11-20');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (98, 22, 'Completed', '84 Stuart Pass', '2022-10-07');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (81, 75, 'Completed', '92 Arizona Drive', '2023-02-01');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (24, 13, 'Completed', '58 Northfield Court', '2022-07-13');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (25, 37, 'In Progress', '736 Brown Circle', '2023-02-28');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (30, 10, 'Completed', '812 Dorton Pass', '2022-08-17');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (17, 75, 'Completed', '172 Buell Junction', '2023-03-14');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (15, 100, 'Completed', '9604 Ridge Oak Parkway', '2022-08-23');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (63, 61, 'Completed', '9442 Jana Crossing', '2023-02-18');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (44, 100, 'In Progress', '248 Moland Hill', '2022-09-10');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (78, 99, 'In Progress', '38 Washington Way', '2023-03-14');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (24, 45, 'In Progress', '7 Cottonwood Drive', '2023-03-31');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (27, 89, 'In Progress', '357 Toban Terrace', '2023-05-29');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (2, 47, 'Completed', '68 Service Point', '2023-01-05');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (93, 79, 'Completed', '61 Ryan Crossing', '2022-07-29');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (78, 62, 'Completed', '85035 Golf Street', '2023-07-04');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (17, 87, 'In Progress', '50 Chinook Trail', '2022-08-31');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (14, 3, 'In Progress', '04887 Sundown Lane', '2022-09-25');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (58, 27, 'In Progress', '4 Jana Road', '2022-09-26');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (62, 63, 'In Progress', '614 Logan Plaza', '2022-09-16');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (3, 2, 'Completed', '25 Memorial Junction', '2022-11-14');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (1, 82, 'In Progress', '66 Coleman Way', '2023-03-10');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (70, 28, 'In Progress', '7 Elmside Court', '2023-04-07');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (35, 54, 'Completed', '25 Cambridge Alley', '2023-05-07');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (94, 63, 'Completed', '81 Utah Plaza', '2022-08-25');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (91, 3, 'In Progress', '8157 Sutherland Lane', '2022-07-17');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (51, 44, 'In Progress', '18397 Farmco Crossing', '2022-12-15');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (84, 23, 'In Progress', '3 Karstens Crossing', '2023-02-02');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (30, 97, 'Completed', '568 Paget Street', '2023-02-28');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (75, 7, 'Completed', '139 Spenser Park', '2022-10-15');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (90, 82, 'Completed', '73 Forest Road', '2022-12-10');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (88, 4, 'In Progress', '40834 Loeprich Avenue', '2022-08-04');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (14, 61, 'Completed', '0 Gateway Court', '2022-08-21');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (80, 96, 'Completed', '08 Atwood Terrace', '2023-06-18');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (62, 33, 'Completed', '990 Warbler Court', '2022-07-28');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (7, 73, 'In Progress', '5801 Atwood Trail', '2022-12-10');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (58, 1, 'In Progress', '0 Bayside Terrace', '2023-01-13');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (50, 84, 'In Progress', '24 Red Cloud Crossing', '2022-07-31');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (30, 21, 'In Progress', '960 Melvin Hill', '2022-11-12');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (93, 68, 'In Progress', '19 Express Center', '2022-12-31');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (31, 20, 'In Progress', '35 Lukken Center', '2022-11-07');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (64, 98, 'In Progress', '80594 Fordem Alley', '2023-01-17');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (43, 71, 'Completed', '32284 Anniversary Place', '2023-07-09');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (83, 16, 'Completed', '849 Merry Pass', '2023-04-29');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (29, 78, 'Completed', '96 Summer Ridge Park', '2022-10-01');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (93, 10, 'In Progress', '023 Nancy Place', '2023-05-15');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (61, 93, 'In Progress', '0546 Becker Hill', '2023-02-08');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (74, 82, 'Completed', '76 Waxwing Street', '2023-01-17');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (69, 11, 'Completed', '9534 Rockefeller Street', '2022-12-20');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (81, 53, 'In Progress', '9 Pond Place', '2023-02-25');
insert into Delivery (order_id, delivery_person_id, status, address, delivery_date) values (46, 28, 'In Progress', '3930 1st Circle', '2023-05-27');

insert into Coupon (code, discount, expiry_date) values ('5982-5700', 9.37, '2024-05-26');
insert into Coupon (code, discount, expiry_date) values ('8122-1596', 8.81, '2024-08-06');
insert into Coupon (code, discount, expiry_date) values ('5679-5803', 9.01, '2024-03-05');
insert into Coupon (code, discount, expiry_date) values ('6982-7670', 7.07, '2024-10-04');
insert into Coupon (code, discount, expiry_date) values ('5894-5985', 8.43, '2024-03-16');
insert into Coupon (code, discount, expiry_date) values ('4995-4721', 9.85, '2025-02-14');
insert into Coupon (code, discount, expiry_date) values ('7190-7436', 9.99, '2024-12-09');
insert into Coupon (code, discount, expiry_date) values ('9060-9110', 8.66, '2025-04-23');
insert into Coupon (code, discount, expiry_date) values ('2819-1753', 8.56, '2025-05-07');
insert into Coupon (code, discount, expiry_date) values ('0121-0921', 2.71, '2024-03-17');
insert into Coupon (code, discount, expiry_date) values ('3281-3110', 4.01, '2025-03-13');
insert into Coupon (code, discount, expiry_date) values ('9776-8143', 7.34, '2024-06-04');
insert into Coupon (code, discount, expiry_date) values ('6661-7484', 5.54, '2024-11-03');
insert into Coupon (code, discount, expiry_date) values ('9830-8120', 7.92, '2024-09-19');
insert into Coupon (code, discount, expiry_date) values ('0977-2246', 1.05, '2024-08-11');
insert into Coupon (code, discount, expiry_date) values ('4047-5075', 6.88, '2025-04-15');
insert into Coupon (code, discount, expiry_date) values ('0159-5419', 9.32, '2025-03-31');
insert into Coupon (code, discount, expiry_date) values ('6023-8564', 4.4, '2024-05-31');
insert into Coupon (code, discount, expiry_date) values ('2301-9877', 2.22, '2024-04-16');
insert into Coupon (code, discount, expiry_date) values ('9608-0304', 1.6, '2024-09-18');
insert into Coupon (code, discount, expiry_date) values ('0394-0955', 1.22, '2025-03-23');
insert into Coupon (code, discount, expiry_date) values ('8255-2010', 9.2, '2024-11-07');
insert into Coupon (code, discount, expiry_date) values ('2539-3452', 8.96, '2024-04-11');
insert into Coupon (code, discount, expiry_date) values ('9354-8541', 5.47, '2025-04-01');
insert into Coupon (code, discount, expiry_date) values ('7435-2509', 8.65, '2025-03-27');
insert into Coupon (code, discount, expiry_date) values ('8791-4353', 1.68, '2025-04-04');
insert into Coupon (code, discount, expiry_date) values ('2305-4416', 6.95, '2024-06-08');
insert into Coupon (code, discount, expiry_date) values ('5960-8194', 7.22, '2024-10-18');
insert into Coupon (code, discount, expiry_date) values ('7545-7210', 6.29, '2024-04-09');
insert into Coupon (code, discount, expiry_date) values ('2895-0255', 2.89, '2025-04-05');
insert into Coupon (code, discount, expiry_date) values ('7025-1310', 3.85, '2025-02-05');
insert into Coupon (code, discount, expiry_date) values ('7737-5175', 8.29, '2025-01-31');
insert into Coupon (code, discount, expiry_date) values ('7442-7941', 7.85, '2024-06-19');
insert into Coupon (code, discount, expiry_date) values ('9200-8122', 1.77, '2025-06-03');
insert into Coupon (code, discount, expiry_date) values ('9621-3429', 1.12, '2024-10-27');
insert into Coupon (code, discount, expiry_date) values ('1635-7330', 9.69, '2024-04-14');
insert into Coupon (code, discount, expiry_date) values ('4281-3582', 6.07, '2024-09-29');
insert into Coupon (code, discount, expiry_date) values ('5421-5310', 4.35, '2024-12-11');
insert into Coupon (code, discount, expiry_date) values ('4996-6381', 6.95, '2024-06-12');
insert into Coupon (code, discount, expiry_date) values ('6976-5731', 6.37, '2025-06-06');
insert into Coupon (code, discount, expiry_date) values ('5382-2143', 5.89, '2024-12-15');
insert into Coupon (code, discount, expiry_date) values ('5162-1367', 8.44, '2024-07-05');
insert into Coupon (code, discount, expiry_date) values ('9073-0133', 9.4, '2024-12-10');
insert into Coupon (code, discount, expiry_date) values ('9167-8579', 9.11, '2024-04-30');
insert into Coupon (code, discount, expiry_date) values ('0222-2563', 3.14, '2024-07-02');
insert into Coupon (code, discount, expiry_date) values ('4521-8802', 1.99, '2024-10-26');
insert into Coupon (code, discount, expiry_date) values ('8647-1071', 5.78, '2024-09-10');
insert into Coupon (code, discount, expiry_date) values ('7079-4271', 5.51, '2024-10-06');
insert into Coupon (code, discount, expiry_date) values ('7296-3411', 4.94, '2024-11-11');
insert into Coupon (code, discount, expiry_date) values ('1681-2913', 8.7, '2024-03-22');
insert into Coupon (code, discount, expiry_date) values ('7450-6584', 1.94, '2025-04-21');
insert into Coupon (code, discount, expiry_date) values ('7867-0064', 7.76, '2024-12-21');
insert into Coupon (code, discount, expiry_date) values ('9671-9419', 7.35, '2024-08-03');
insert into Coupon (code, discount, expiry_date) values ('1095-6938', 9.75, '2024-08-02');
insert into Coupon (code, discount, expiry_date) values ('3076-4724', 1.76, '2024-10-20');
insert into Coupon (code, discount, expiry_date) values ('3825-4820', 6.41, '2024-05-31');
insert into Coupon (code, discount, expiry_date) values ('1252-7230', 3.39, '2024-03-21');
insert into Coupon (code, discount, expiry_date) values ('1449-1351', 8.69, '2024-08-10');
insert into Coupon (code, discount, expiry_date) values ('3095-7431', 9.97, '2024-04-24');
insert into Coupon (code, discount, expiry_date) values ('7525-3264', 3.32, '2025-05-15');
insert into Coupon (code, discount, expiry_date) values ('5200-3929', 2.59, '2024-12-31');
insert into Coupon (code, discount, expiry_date) values ('4373-8093', 1.09, '2024-04-29');
insert into Coupon (code, discount, expiry_date) values ('3478-9003', 3.07, '2025-01-03');
insert into Coupon (code, discount, expiry_date) values ('7042-7085', 5.6, '2025-02-10');
insert into Coupon (code, discount, expiry_date) values ('4183-1640', 2.52, '2024-09-19');
insert into Coupon (code, discount, expiry_date) values ('6081-3554', 6.15, '2024-06-20');
insert into Coupon (code, discount, expiry_date) values ('0335-2283', 2.07, '2024-08-09');
insert into Coupon (code, discount, expiry_date) values ('8814-9611', 1.76, '2025-04-13');
insert into Coupon (code, discount, expiry_date) values ('0442-6948', 6.41, '2024-03-17');
insert into Coupon (code, discount, expiry_date) values ('4171-5205', 5.39, '2024-05-26');
insert into Coupon (code, discount, expiry_date) values ('4592-2951', 6.76, '2024-09-17');
insert into Coupon (code, discount, expiry_date) values ('6236-2243', 3.37, '2024-12-06');
insert into Coupon (code, discount, expiry_date) values ('2769-1952', 8.1, '2024-06-12');
insert into Coupon (code, discount, expiry_date) values ('6947-4567', 7.49, '2025-04-12');
insert into Coupon (code, discount, expiry_date) values ('2319-6382', 1.18, '2024-11-20');
insert into Coupon (code, discount, expiry_date) values ('8278-6171', 4.69, '2025-04-19');
insert into Coupon (code, discount, expiry_date) values ('2903-7695', 3.5, '2024-07-01');
insert into Coupon (code, discount, expiry_date) values ('9311-1043', 6.75, '2024-07-05');
insert into Coupon (code, discount, expiry_date) values ('8603-1761', 2.14, '2024-11-06');
insert into Coupon (code, discount, expiry_date) values ('9369-2178', 9.84, '2024-05-11');
insert into Coupon (code, discount, expiry_date) values ('7659-5263', 8.21, '2024-05-21');
insert into Coupon (code, discount, expiry_date) values ('2747-7911', 9.3, '2024-12-12');
insert into Coupon (code, discount, expiry_date) values ('0661-5214', 5.82, '2024-04-28');
insert into Coupon (code, discount, expiry_date) values ('2375-0570', 8.24, '2025-03-20');
insert into Coupon (code, discount, expiry_date) values ('6986-9115', 6.92, '2024-11-23');
insert into Coupon (code, discount, expiry_date) values ('6648-5894', 2.21, '2025-06-04');
insert into Coupon (code, discount, expiry_date) values ('4924-8578', 2.01, '2024-05-10');
insert into Coupon (code, discount, expiry_date) values ('3290-5147', 8.19, '2024-09-12');
insert into Coupon (code, discount, expiry_date) values ('6317-4073', 2.21, '2025-04-12');
insert into Coupon (code, discount, expiry_date) values ('2849-7543', 4.69, '2025-01-11');
insert into Coupon (code, discount, expiry_date) values ('1567-0920', 5.97, '2024-06-05');
insert into Coupon (code, discount, expiry_date) values ('9116-2537', 8.98, '2025-05-14');
insert into Coupon (code, discount, expiry_date) values ('3554-0305', 2.38, '2025-04-30');
insert into Coupon (code, discount, expiry_date) values ('5024-9055', 7.35, '2025-04-22');
insert into Coupon (code, discount, expiry_date) values ('4458-6560', 4.58, '2024-05-29');
insert into Coupon (code, discount, expiry_date) values ('1023-7121', 3.81, '2024-05-25');
insert into Coupon (code, discount, expiry_date) values ('7762-7153', 4.76, '2024-03-26');
insert into Coupon (code, discount, expiry_date) values ('4006-3215', 7.67, '2024-10-01');
insert into Coupon (code, discount, expiry_date) values ('7218-4210', 9.75, '2025-01-07');
insert into Coupon (code, discount, expiry_date) values ('8312-2549', 5.63, '2024-10-25');

insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (89, 81, '2022-07-16', 25.9, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (23, null, '2023-05-11', 110.2, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (55, null, '2023-07-05', 100.68, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (90, null, '2023-06-06', 43.85, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (29, null, '2022-09-20', 30.45, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (36, 90, '2023-01-26', 138.02, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (6, null, '2022-08-30', 148.47, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (55, null, '2022-11-18', 62.8, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (100, null, '2023-01-31', 115.58, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (93, null, '2022-11-16', 81.49, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (28, null, '2023-01-12', 37.11, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (79, null, '2023-05-03', 46.02, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (88, 39, '2022-12-29', 20.05, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (26, null, '2023-01-11', 129.78, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (47, null, '2022-12-27', 6.21, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (33, null, '2022-09-07', 138.04, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (54, null, '2022-10-18', 15.99, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (6, 28, '2022-11-07', 147.46, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (87, null, '2022-09-16', 128.22, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (93, null, '2023-05-07', 42.94, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (19, null, '2022-11-04', 26.06, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (56, 77, '2022-08-12', 33.61, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (50, null, '2023-02-25', 44.41, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (57, null, '2023-06-16', 75.1, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (29, null, '2023-06-14', 17.65, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (74, null, '2022-11-21', 12.14, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (99, 85, '2023-02-10', 19.78, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (81, null, '2023-02-15', 82.96, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (68, null, '2022-07-16', 70.07, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (83, null, '2022-09-14', 5.58, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (99, null, '2023-05-26', 11.94, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (36, null, '2023-01-21', 142.89, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (83, null, '2023-03-29', 116.79, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (10, null, '2022-09-03', 49.04, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (6, null, '2023-06-27', 125.03, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (63, null, '2022-11-19', 111.8, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (100, 95, '2022-10-10', 67.78, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (78, null, '2022-08-03', 112.4, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (49, null, '2022-11-03', 136.06, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (54, null, '2023-06-17', 7.94, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (40, null, '2023-05-11', 73.49, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (7, null, '2022-10-01', 129.2, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (95, null, '2023-06-18', 61.72, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (26, 23, '2022-08-02', 39.9, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (4, null, '2023-03-02', 125.85, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (87, null, '2022-11-23', 7.32, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (85, null, '2022-10-18', 118.48, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (31, null, '2022-10-14', 141.01, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (95, null, '2023-02-04', 83.77, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (19, null, '2022-07-29', 133.33, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (59, null, '2023-05-13', 73.51, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (79, null, '2023-01-12', 125.9, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (39, null, '2022-08-15', 63.77, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (58, null, '2022-08-29', 121.63, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (28, null, '2023-06-27', 141.28, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (84, null, '2022-12-27', 97.53, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (31, null, '2023-02-11', 118.66, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (72, 28, '2023-05-27', 5.01, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (81, null, '2023-04-18', 106.67, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (90, 76, '2022-10-20', 127.43, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (21, null, '2022-10-16', 106.59, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (98, null, '2023-04-14', 31.35, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (65, 99, '2022-08-14', 69.12, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (45, null, '2023-04-23', 52.04, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (67, 97, '2023-05-11', 8.68, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (55, null, '2022-08-12', 100.51, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (51, null, '2023-05-20', 75.5, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (44, 55, '2023-01-20', 35.78, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (40, 92, '2023-04-14', 85.23, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (43, 48, '2023-07-09', 18.36, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (85, null, '2023-03-25', 79.03, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (19, null, '2023-04-03', 45.65, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (34, null, '2023-01-04', 100.99, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (41, 77, '2023-03-02', 39.15, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (5, null, '2023-07-09', 76.15, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (6, null, '2023-01-03', 15.55, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (11, null, '2023-05-05', 92.27, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (7, null, '2023-04-10', 130.31, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (86, 10, '2022-07-27', 97.88, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (80, null, '2023-04-30', 16.46, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (15, 24, '2023-01-17', 139.42, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (45, null, '2022-08-22', 144.7, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (36, null, '2022-09-20', 146.45, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (88, null, '2022-10-17', 131.77, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (46, null, '2023-02-20', 47.31, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (84, null, '2022-09-20', 97.8, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (81, null, '2022-11-14', 115.54, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (58, null, '2023-05-08', 45.01, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (73, null, '2023-02-15', 115.0, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (42, null, '2022-08-16', 40.75, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (49, null, '2023-02-19', 48.27, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (53, null, '2023-05-03', 80.86, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (7, null, '2022-09-16', 64.96, 'PayPal');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (27, null, '2022-09-20', 54.33, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (76, 31, '2023-07-04', 44.41, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (27, 92, '2023-04-08', 23.6, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (27, null, '2023-02-14', 79.8, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (56, 8, '2023-01-19', 21.54, 'Card');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (80, null, '2023-02-08', 60.54, 'Cash');
insert into PaymentTransaction (order_id, coupon_id, payment_date, total, method) values (28, null, '2023-04-22', 124.66, 'PayPal');

-- QUERIES 

-- F. 1.
SELECT c.name as Customer, o.order_date, menui.name as Items
FROM customer c
JOIN `order` o ON o.customer_id = c.id
JOIN orderitem oi ON oi.order_id = o.id
JOIN menuitem menui ON oi.item_id = menui.id
WHERE o.order_date > '2022-01-01' AND o.order_date < '2023-01-01';

-- F.2.
SELECT c.name AS CustomerName, SUM(pt.total) AS TotalSpent
FROM Customer c
JOIN `Order` o ON c.id = o.customer_id
JOIN PaymentTransaction pt ON o.id = pt.order_id
GROUP BY c.id
ORDER BY TotalSpent DESC
LIMIT 3;

-- F. 3.
SELECT
    CONCAT('PeriodOfSales: ', '2022-01-01', ' – ', '2025-01-01') AS PeriodOfSales,
    SUM(pt.total) AS "TotalSales",
    SUM(pt.total) / 3 AS "YearlyAverage",
    SUM(pt.total) / (3 * 12) AS "MonthlyAverage"
FROM `Order` o
JOIN PaymentTransaction pt ON o.id = pt.order_id
WHERE o.order_date BETWEEN '2022-01-01' AND '2025-01-01';



-- F. 4.
SELECT 
    dp.country AS GeographicalLocation,
    SUM(pt.total) AS TotalSales
FROM DeliveryPerson dp
JOIN Delivery dr ON dp.id = dr.delivery_person_id
JOIN `Order` o ON dr.order_id = o.id
JOIN PaymentTransaction pt ON o.id = pt.order_id
GROUP BY dp.country;

-- F.5.
SELECT DISTINCT 
    r.address AS Location
FROM `Order` o
JOIN OrderItem oi ON o.id = oi.order_id
JOIN MenuItem mi ON oi.item_id = mi.id
JOIN Restaurant r ON mi.restaurant_id = r.id
WHERE EXISTS (
    SELECT 1
    FROM Review rev
    WHERE rev.order_id = o.id
);

-- VIEWS

CREATE OR REPLACE VIEW InvoiceHeader AS
SELECT 
    o.id AS OrderID,
    o.order_date AS OrderDate,
    c.name AS CustomerName,
    c.email AS CustomerEmail,
    c.address AS CustomerAddress,
    r.name AS RestaurantName,
    r.address AS RestaurantAddress,
    SUM(oi.quantity * mi.price) AS TotalOrderAmount
FROM `Order` o
JOIN Customer c ON o.customer_id = c.id
JOIN Restaurant r ON o.restaurant_id = r.id
JOIN OrderItem oi ON o.id = oi.order_id
JOIN MenuItem mi ON oi.item_id = mi.id
GROUP BY o.id, o.order_date, c.name, c.email, c.address, r.name, r.address;

SELECT * FROM InvoiceHeader WHERE OrderID = 28;

CREATE OR REPLACE VIEW InvoiceDetails AS
SELECT 
    o.id AS OrderID,
    mi.name AS ItemName,
    oi.quantity AS Quantity,
    mi.price AS PricePerItem,
    oi.quantity * mi.price AS TotalPrice
FROM `Order` o
JOIN OrderItem oi ON o.id = oi.order_id
JOIN MenuItem mi ON oi.item_id = mi.id;

SELECT * FROM InvoiceDetails WHERE OrderID = 28;
