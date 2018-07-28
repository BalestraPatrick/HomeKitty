DO $$
BEGIN
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 0) WHERE id = 0;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 1) WHERE id = 1;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 2) WHERE id = 2;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 3) WHERE id = 3;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 4) WHERE id = 4;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 5) WHERE id = 5;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 6) WHERE id = 6;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 7) WHERE id = 7;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 8) WHERE id = 8;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 9) WHERE id = 9;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 10) WHERE id = 10;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 11) WHERE id = 11;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 12) WHERE id = 12;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 13) WHERE id = 13;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 14) WHERE id = 14;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 15) WHERE id = 15;
UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = 16) WHERE id = 16;
END $$;
