-- Birthday Edit price snapshot, 2026-11-10. Run once in Supabase SQL Editor.
-- Safe for existing gift reservations and PIN: only product prices are updated.
UPDATE public.products SET price_cents = CASE
 WHEN product_url LIKE '%aventino-029-008-049%' THEN 24500
 WHEN product_url LIKE '%nicolette-knit-dress-black%' THEN 18800
 WHEN product_url LIKE '%vertuo-pop-plus-matteblack-gold%' THEN 10999
 WHEN product_url LIKE '%double-ball-earring-shashi%' THEN 6800
 WHEN product_url LIKE '%cable-hooded-scarf-hat-attack%' THEN 10200
 WHEN product_url LIKE '%standard-room-kit%' THEN 19000
 WHEN product_url LIKE '%cyprus-mule-brown-leather%' THEN 26300
 ELSE price_cents END
WHERE product_url LIKE '%aventino-029-008-049%'
 OR product_url LIKE '%nicolette-knit-dress-black%'
 OR product_url LIKE '%vertuo-pop-plus-matteblack-gold%'
 OR product_url LIKE '%double-ball-earring-shashi%'
 OR product_url LIKE '%cable-hooded-scarf-hat-attack%'
 OR product_url LIKE '%standard-room-kit%'
 OR product_url LIKE '%cyprus-mule-brown-leather%';
SELECT name, price_cents / 100.0 AS price_usd FROM public.products ORDER BY sort_order;
