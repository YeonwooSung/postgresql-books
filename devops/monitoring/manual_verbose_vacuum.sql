
-- 수동으로 VACUUM을 실행.
-- VACUUM VERBOSE는 VACUUM이 실행되는 동안에도 진행 상황을 보여준다.
-- 따라서, 이 쿼리를 통해 auto vacuum 지연이 발생하는 이유 등을 직관적으로 확인할 수도 있게 된다.

vacuum VERBOSE public.t_product;
