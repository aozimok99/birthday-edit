-- ONE-TIME SETUP for GitHub-only new gifts. Existing tables and reservations stay untouched.
CREATE TABLE IF NOT EXISTS public.github_gift_reservations (
  gift_key text PRIMARY KEY,
  reserved_by text NOT NULL CHECK (char_length(btrim(reserved_by)) BETWEEN 1 AND 60),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT gift_key_format CHECK (gift_key ~ '^[a-z0-9][a-z0-9_-]{0,99}$')
);
ALTER TABLE public.github_gift_reservations ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.github_gift_reservations FROM PUBLIC, anon, authenticated;
CREATE OR REPLACE FUNCTION public.github_gift_reservation(
  p_pin text, p_gift_key text, p_person text, p_action text
) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE changed integer;
BEGIN
  IF NOT private.valid_store_pin(p_pin) THEN
    RAISE EXCEPTION 'Invalid passphrase';
  END IF;
  IF p_gift_key IS NULL OR p_gift_key !~ '^[a-z0-9][a-z0-9_-]{0,99}$' THEN
    RAISE EXCEPTION 'Invalid gift key';
  END IF;
  IF p_person IS NULL OR char_length(btrim(p_person)) NOT BETWEEN 1 AND 60 THEN
    RAISE EXCEPTION 'Invalid name';
  END IF;
  IF p_action = 'reserve' THEN
    INSERT INTO public.github_gift_reservations(gift_key,reserved_by)
    VALUES(p_gift_key,btrim(p_person)) ON CONFLICT DO NOTHING;
  ELSIF p_action = 'release' THEN
    DELETE FROM public.github_gift_reservations
    WHERE gift_key=p_gift_key AND reserved_by=p_person;
  ELSE
    RAISE EXCEPTION 'Invalid action';
  END IF;
  GET DIAGNOSTICS changed = ROW_COUNT;
  RETURN changed > 0;
END;
$$;
CREATE OR REPLACE FUNCTION public.list_github_gift_reservations(p_pin text)
RETURNS TABLE(gift_key text, reserved_by text)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  IF NOT private.valid_store_pin(p_pin) THEN
    RAISE EXCEPTION 'Invalid passphrase';
  END IF;
  RETURN QUERY SELECT r.gift_key,r.reserved_by FROM public.github_gift_reservations r;
END;
$$;
REVOKE ALL ON FUNCTION public.github_gift_reservation(text,text,text,text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.list_github_gift_reservations(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.github_gift_reservation(text,text,text,text) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.list_github_gift_reservations(text) TO anon,authenticated;
