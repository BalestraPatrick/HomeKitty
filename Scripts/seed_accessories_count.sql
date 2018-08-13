DO $$
DECLARE
   counter INTEGER := 0; 
BEGIN
   WHILE counter <= (SELECT COUNT(*) FROM category) LOOP
      UPDATE category SET accessories_count = (SELECT COUNT(*) FROM accessories WHERE category_id = counter) WHERE id = counter;
      counter := counter + 1;
   END LOOP;
END $$;
