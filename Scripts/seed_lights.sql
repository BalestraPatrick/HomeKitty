DO $$
DECLARE category_name TEXT;
BEGIN
category_name := 'Lights';
INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'C-Sleep bulb with C', 'https://cdn.shopify.com/s/files/1/0971/2628/t/22/assets/sleep.png','$74.99', 'https://www.cbyge.com/products/c-sleep', (SELECT id FROM manufacturer WHERE name LIKE 'C by GE'), TRUE, '2017-09-29', TRUE, FALSE, NULL, false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'C-Life bulb with C', 'https://cdn.shopify.com/s/files/1/0971/2628/t/22/assets/life.png?17490324039130128060','$74.99', 'https://www.cbyge.com/products/c-life', (SELECT id FROM manufacturer WHERE name LIKE 'C by GE'), TRUE, '2017-09-26', FALSE, FALSE, NULL, false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Nanoleaf Aurora Lighting Smarter Kit', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/KW/HKW32/HKW32','$199.95', 'https://www.apple.com/shop/product/HKW32VC/A/nanoleaf-aurora-lighting-smarter-kit', (SELECT id FROM manufacturer WHERE name LIKE 'Nanoleaf'), TRUE, '2017-09-29', TRUE, FALSE, NULL, false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Nanoleaf Ivy Smarter Kit', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/L2/HL282/HL282','$99.95', 'https://www.apple.com/shop/product/HL282VC/A/nanoleaf-ivy-smarter-kit', (SELECT id FROM manufacturer WHERE name LIKE 'Nanoleaf'), TRUE, '2017-09-25', FALSE, FALSE, NULL, false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Incipio CommandKit Smart Light Bulb Adapter with Dimming', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/L2/HL2V2/HL2V2','$39.95', 'https://www.apple.com/shop/product/HL2V2VC/A/incipio-commandkit-smart-light-bulb-adapter-with-dimming', (SELECT id FROM manufacturer WHERE name LIKE 'Incipio'), TRUE, '2017-09-29', TRUE, FALSE, NULL, false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Philips Hue White Extension Bulb A19 E26', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/JC/HJC42/HJC42','$14.95', 'https://www.apple.com/shop/product/HJC42LL/B/philips-hue-white-extension-bulb-a19-e26', (SELECT id FROM manufacturer WHERE name LIKE 'Philips'), TRUE, '2017-09-19', FALSE, TRUE, (SELECT id FROM accessories WHERE name LIKE 'Philips Hue Bridge 2.0'), false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Philips Hue Ambiance White and Color Extension Bulb A19 E26', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/JC/HJCC2/HJCC2','$49.95', 'https://www.apple.com/shop/product/HJCC2VC/B/philips-hue-ambiance-white-and-color-extension-bulb-a19-e26', (SELECT id FROM manufacturer WHERE name LIKE 'Philips'), TRUE, '2017-09-29', TRUE, TRUE, (SELECT id FROM accessories WHERE name LIKE 'Philips Hue Bridge 2.0'), false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Philips Hue White Starter Kit A19 E26', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/JC/HJCB2/HJCB2','$69.95', 'https://www.apple.com/shop/product/HJCB2LL/B/philips-hue-white-starter-kit-a19-e26', (SELECT id FROM manufacturer WHERE name LIKE 'Philips'), TRUE, '2017-09-29', TRUE, TRUE, (SELECT id FROM accessories WHERE name LIKE 'Philips Hue Bridge 2.0'), false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Philips Hue White Ambiance A19 Bulb', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/K8/HK8U2/HK8U2','$29.95', 'https://www.apple.com/shop/product/HK8U2VC/B/philips-hue-white-ambiance-a19-bulb', (SELECT id FROM manufacturer WHERE name LIKE 'Philips'), TRUE, '2017-09-15', FALSE, TRUE, (SELECT id FROM accessories WHERE name LIKE 'Philips Hue Bridge 2.0'), false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Philips Hue Lightstrip Plus Extension Set (3 ft./1 m)', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/JC/HJC62/HJC62','$29.95', 'https://www.apple.com/shop/product/HJC62VC/B/philips-hue-lightstrip-plus-extension-set-3-ft-1-m', (SELECT id FROM manufacturer WHERE name LIKE 'Philips'), TRUE, '2017-09-29', TRUE, TRUE, (SELECT id FROM accessories WHERE name LIKE 'Philips Hue Bridge 2.0'), false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Philips Hue Ambience Downlight Bulb BR30 E26', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/JC/HJCT2/HJCT2','$49.95', 'https://www.apple.com/shop/product/HJCT2VC/B/philips-hue-ambience-downlight-bulb-br30-e26', (SELECT id FROM manufacturer WHERE name LIKE 'Philips'), TRUE, '2017-09-29', FALSE, TRUE, (SELECT id FROM accessories WHERE name LIKE 'Philips Hue Bridge 2.0'), false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Philips Hue Go', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/HL/HHLD2/HHLD2','$79.95', 'https://www.apple.com/shop/product/HHLD2VC/B/philips-hue-go', (SELECT id FROM manufacturer WHERE name LIKE 'Philips'), TRUE, '2017-09-29', TRUE, TRUE, (SELECT id FROM accessories WHERE name LIKE 'Philips Hue Bridge 2.0'), false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Philips Hue Lightstrip Plus', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/JC/HJC52/HJC52','$89.95', 'https://www.apple.com/shop/product/HJC52VC/B/philips-hue-lightstrip-plus', (SELECT id FROM manufacturer WHERE name LIKE 'Philips'), TRUE, '2017-09-29', TRUE, TRUE, (SELECT id FROM accessories WHERE name LIKE 'Philips Hue Bridge 2.0'), false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Philips Hue White Ambiance A19 Starter Kit', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/K8/HK8T2/HK8T2','$129.95', 'https://www.apple.com/shop/product/HK8T2VC/B/philips-hue-white-ambiance-a19-starter-kit', (SELECT id FROM manufacturer WHERE name LIKE 'Philips'), TRUE, '2017-09-11', TRUE, TRUE, (SELECT id FROM accessories WHERE name LIKE 'Philips Hue Bridge 2.0'), false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Philips Hue White and Color Wireless Ambiance Starter Kit A19 E26', 'https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/H/JC/HJCA2/HJCA2','$199.95', 'https://www.apple.com/shop/product/HJCA2VC/B/philips-hue-white-and-color-wireless-ambiance-starter-kit-a19-e26', (SELECT id FROM manufacturer WHERE name LIKE 'Philips'), TRUE, '2017-09-29', TRUE, TRUE, (SELECT id FROM accessories WHERE name LIKE 'Philips Hue Bridge 2.0'), false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Avea Bulb', 'http://www.icentre.com.mt/content/images/thumbs/0001993_elgato-avea-smart-led-bulb_550.jpeg','$39.95', 'https://www.elgato.com/en/avea', (SELECT id FROM manufacturer WHERE name LIKE 'Elgato'), TRUE, '2017-09-29', TRUE, FALSE, NULL, false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Avea Flare', 'https://www.overclockers.co.uk/media/image/thumbnail/NW007EL_152325_800x800.png','$99.95', 'https://www.elgato.com/en/avea', (SELECT id FROM manufacturer WHERE name LIKE 'Elgato'), TRUE, '2017-09-29', TRUE, FALSE, NULL, false);

INSERT INTO accessories (category_id, name, image, price, product_link, manufacturer_id, approved, date, released, requires_hub, required_hub_id, featured) VALUES
((SELECT id FROM category WHERE name LIKE category_name), 'Avea Sphere', 'https://dice.bg/content/pics/26499_elgato-avea-sphere-led-osvetitelno-tqlo-za-mobilni-ustroistva-s-ios-i-android_804297948.jpg','$99.95', 'https://www.elgato.com/en/avea', (SELECT id FROM manufacturer WHERE name LIKE 'Elgato'), TRUE, '2017-09-29', TRUE, FALSE, NULL, false);
END $$;
