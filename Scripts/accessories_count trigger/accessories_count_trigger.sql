-- Function
CREATE OR REPLACE FUNCTION "public"."update_count"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
	DECLARE
	new_category_count int;
	old_category_count int;
	BEGIN
	-- If approved status changes to TRUE and manufacturer is the same, increase count by 1.
	old_category_count = (SELECT accessories_count FROM CATEGORY WHERE ID = OLD.category_id);
	new_category_count = (SELECT accessories_count FROM CATEGORY WHERE ID = NEW.category_id);
	IF (NEW.approved != OLD.approved AND NEW.approved = TRUE AND NEW.category_id = OLD.category_id) THEN
		UPDATE CATEGORY
		SET accessories_count = new_category_count + 1
		WHERE NEW.category_id = CATEGORY.ID;
-- 		RAISE EXCEPTION 'Category: [%] increased to: [%]', NEW.ID, new_category_count + 1;
	-- If approved status changes to FALSE and manufacturer is the same, decrease count by 1.
	ELSIF (NEW.approved != OLD.approved AND NEW.approved = FALSE AND NEW.category_id = OLD.category_id) THEN
		UPDATE CATEGORY
		SET accessories_count = new_category_count - 1
		WHERE NEW.category_id = CATEGORY.ID;
	ELSIF (NEW.category_id != OLD.category_id) THEN
		-- decrease old category count.
		UPDATE CATEGORY
		SET accessories_count = old_category_count - 1
		WHERE OLD.category_id = CATEGORY.ID;
		-- increase new category count.
		UPDATE CATEGORY
		SET accessories_count = new_category_count + 1
		WHERE NEW.category_id = CATEGORY.ID;
-- 		RAISE EXCEPTION 'Old Category: [%], decreased to: [%], New category: [%], increase to: [%]', OLD.ID, old_category_count - 1, NEW.ID, new_category_count + 1;
	END IF;
  RETURN null;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100

-- Trigger
CREATE TRIGGER "update_count_trigger" AFTER UPDATE OF "category_id", "approved" ON "public"."accessories"
FOR EACH ROW
EXECUTE PROCEDURE "public"."update_count"();