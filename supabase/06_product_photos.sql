-- Exact retailer image verified from Larroude's Cyprus Mule listing.
-- Only changes image_url for this one product. PIN and reservations untouched.
UPDATE public.products
SET image_url = 'https://larroude.com/cdn/shop/files/L545-CYPR-BROW-2926_4.webp?v=1781037568'
WHERE product_url LIKE '%cyprus-mule-brown-leather%';
