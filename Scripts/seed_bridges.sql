DO $$
DECLARE category_name TEXT;
BEGIN
category_name := 'Bridges';
INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requireshub, requiredhub_id) VALUES ((SELECT id FROM category WHERE name LIKE category_name), 'Philips Hue Bridge 2.0', 'https://sm.pcmag.com/t/pcmag_uk/review/p/philips-hu/philips-hue-bridge-20_4wzk.640.jpg','$59.99', 'http://www2.meethue.com/en-us/productdetail/philips-hue-bridge', (SELECT id FROM manufacturer WHERE name LIKE 'Philips'), TRUE, '2017-09-29', TRUE, FALSE, NULL);
END $$;




