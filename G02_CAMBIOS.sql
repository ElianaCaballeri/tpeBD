--La fecha del primer comentario tiene que
--ser anterior a la fecha del último comentario si este no es nulo.
--TIPO TUPLA
ALTER TABLE GR02_COMENTA
ADD CONSTRAINT CK_GR02_FECHA_COMENTARIO
CHECK((fecha_ultimo_com IS NOT NULL AND fecha_primer_com<fecha_ultimo_com)OR (fecha_ultimo_com IS NULL)) ;

--SE EJECUTA CORRECTAMENTE
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(1,1,'2018-05-18','2020-06-20');
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,1,'2018-06-25','2019-03-14');
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,2,'2018-05-18','2020-11-23');
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,3,'2018-05-18',NULL);
--NO PROCEDE
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,2,'2020-05-18','2010-04-17');

--NO PROCEDE POR QUE LA FECHA A CAMBIAR NO CUMPLE CON EL CHECKEO
--UPDATE GR02_COMENTA SET fecha_primer_com='2020-11-19' WHERE id_usuario=2 AND id_juego=1;
--PROCEDE YA QUE LA FECHA DE INICIO CUMPLE CON EL CHECKEO
--UPDATE GR02_COMENTA SET fecha_primer_com='2017-11-19' WHERE id_usuario=2 AND id_juego=1;


--Cada usuario sólo puede comentar una vez al día cada juego.
--TIPO TABLA
/*ALTER TABLE GR02_COMENTARIO
ADD CONSTRAINT CK_GR02_CANT_COMENTARIO_X_DIA
CHECK ( NOT EXISTS (SELECT 1
FROM GR02_COMENTARIO
GROUP BY ID_USUARIO,ID_JUEGO,FECHA_COMENTARIO
HAVING count(*) > 1)) ;
*/
CREATE OR REPLACE FUNCTION TRFN_GR02_fecha_comentario()
RETURNS Trigger AS $$
declare cant_comentarios Integer;
BEGIN
SELECT count(*) INTO cant_comentarios
FROM GR02_COMENTARIO
WHERE id_usuario= NEW.id_usuario AND id_juego= NEW.id_juego AND CAST(fecha_comentario AS DATE)=CAST(NEW.fecha_comentario AS DATE);

IF( cant_comentarios>=1 )THEN
RAISE EXCEPTION 'Error no puede comentar mas de 1 vez al dia por juego';
END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';


CREATE TRIGGER TR_GR02_fecha_comentario
BEFORE INSERT OR UPDATE OF fecha_comentario,id_usuario,id_juego
ON GR02_COMENTARIO
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR02_fecha_comentario();


--los insert son a prueba para demostrar que funciona la consulta interna del chequeo.
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,1,1,now(),'muy buen juego federico');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,1,2,now(),'muy buen juego federico2');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,1,3,now(),'muy buen juego federico3');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(1,1,3,'2020-11-23','muy buen juego');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,2,4,'2020-11-24','PRUEBA');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,2,5,'2020-11-23','PRUEBAAAA2');

--UPDATE GR02_COMENTARIO SET id_juego=1 WHERE id_usuario=2 AND id_juego=2 AND id_comentario=4;
--UPDATE GR02_COMENTARIO SET id_juego=1 ,id_usuario=1 WHERE id_juego=2 AND id_usuario=2 AND id_comentario=4;


--c)Un usuario no puede recomendar un juego si no ha votado previamente dicho juego.
--TIPO GENERAL
/*CREATE ASSERTION VOTAR_ANTES_DE_RECOMENDAR
CHECK(NOT EXISTS(SELECT J.id_usuario
FROM GR02_RECOMENDACION
WHERE id_usuario,id_juego NOT IN (SELECT id_usuario,id_juego
                                   FROM GR02_VOTO)

));*/

CREATE OR REPLACE FUNCTION TRFN_GR02_RECOMENDACION_VOTO()
RETURNS Trigger AS $$
declare
BEGIN
IF NOT EXISTS(SELECT id_usuario,id_juego
FROM GR02_VOTO
WHERE id_usuario= NEW.id_usuario AND id_juego= NEW.id_juego)
THEN
RAISE EXCEPTION 'Error no puede recomendar un juego que no ha votado';
END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR02_RECOMENDACION_VOTO
BEFORE INSERT OR UPDATE OF id_usuario,id_juego
ON GR02_RECOMENDACION
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR02_RECOMENDACION_VOTO();


CREATE OR REPLACE FUNCTION TRFN_GR02_VOTO_RECOMENDACION()
RETURNS Trigger AS $$
declare
BEGIN
IF (TG_OP='UPDATE')THEN
    RAISE EXCEPTION 'Error no puede modificar un voto';
END IF;
IF (TG_OP='DELETE') THEN
    RAISE EXCEPTION 'Error no puede eliminar un voto';
END IF;
END $$
LANGUAGE 'plpgsql';


CREATE TRIGGER TR_GR02_VOTO_RECOMENDACION
BEFORE UPDATE OF id_usuario,id_juego, valor_voto OR DELETE
ON GR02_VOTO
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR02_VOTO_RECOMENDACION();

--PROCEDE
--INSERT INTO GR02_RECOMENDACION (ID_RECOMENDACION, EMAIL_RECOMENDADO, ID_USUARIO, ID_JUEGO) VALUES(1, 'elianacaballeri31@gmail.com',1,23);
--INSERT INTO GR02_JUEGA(finalizado, id_usuario, id_juego) VALUES(null,100,97);
--INSERT INTO GR02_JUEGA(finalizado, id_usuario, id_juego) VALUES(null,100,12); INSERTADO PARA EL EJEMPLO DE INSERT FALLA
--INSERT INTO GR02_VOTO(ID_VOTO,VALOR_VOTO,ID_USUARIO,ID_JUEGO) VALUES (281,5,100,97);
--INTO GR02_RECOMENDACION (ID_RECOMENDACION, EMAIL_RECOMENDADO, ID_USUARIO, ID_JUEGO) VALUES(2, 'elianacaballeri31@gmail.com',100,97);
--UPDATE gr02_recomendacion SET id_usuario=100,id_juego=26 WHERE id_usuario=100 AND id_juego=97;

--FALLA POR RESTRICCION DE TRIGGERS
--UPDATE gr02_voto SET valor_voto=7 WHERE id_usuario=100 AND id_juego=26;
--DELETE FROM gr02_voto WHERE id_usuario=98 AND id_juego=43;
--INSERT INTO GR02_RECOMENDACION (ID_RECOMENDACION, EMAIL_RECOMENDADO, ID_USUARIO, ID_JUEGO) VALUES (3,'PAUCASADO@GMIL',100,12);


--d)Un usuario no puede comentar un juego que no ha jugado.
--TIPO GENERAL
/*CREATE ASSERTION USUARIO_NO_COMENTA_JUEGO
CHECK(NOT EXISTS(SELECT 1
FROM GR02_COMENTA
WHERE (id_usuario, id_juego) IN (SELECT ID_USUARIO,ID_JUEGO
                                   FROM GR02_JUEGA )

));
*/
CREATE OR REPLACE FUNCTION TRFN_GR02_COMENTA_FIJA_JUEGA()
RETURNS Trigger AS $$
declare
BEGIN
IF NOT EXISTS(SELECT id_usuario,id_juego
    FROM GR02_JUEGA
    WHERE id_usuario= NEW.id_usuario AND id_juego= NEW.id_juego)
THEN
RAISE EXCEPTION 'Error no puede comentar un juego que no ha jugado';
END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';


CREATE TRIGGER TR_GR02_COMENTA_JUEGA
BEFORE INSERT OR UPDATE OF id_usuario, id_juego
ON GR02_COMENTA
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR02_COMENTA_FIJA_JUEGA();

CREATE OR REPLACE FUNCTION TRFN_GR02_JUEGA_COMENTA_ESTADOCONSISTENTE()
RETURNS Trigger AS $$
declare
BEGIN
IF(TG_OP='UPDATE') THEN
    UPDATE gr02_comenta SET id_usuario = NEW.id_usuario , id_juego = NEW.id_juego WHERE id_usuario = old.id_usuario AND id_juego = old.id_juego;
    RETURN NEW;
END IF;
IF(TG_OP='DELETE') THEN
    DELETE FROM gr02_comenta WHERE id_usuario = old.id_usuario AND id_juego = old.id_juego;
    RETURN OLD;
END IF;
END $$
LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR02_JUEGA_COMENTA
AFTER DELETE or UPDATE OF id_usuario, id_juego
ON GR02_JUEGA
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR02_JUEGA_COMENTA_ESTADOCONSISTENTE();

--PROCEDEN
--INSERT INTO gr02_comenta (id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (1,74,'2020-11-27','2020-11-28');
--INSERT INTO gr02_comenta (id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (6,96,'2020-11-27','2020-12-27');
--INSERT INTO GR02_JUEGA(finalizado, id_usuario, id_juego) VALUES(null,100,22);
--INSERT INTO gr02_comenta (id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (100,22,'2020-10-27','2020-12-27');
--INSERT INTO gr02_juego (id_juego, nombre_juego, descripcion_juego, id_categoria) VALUES (101,'MORTAL','EL MEJOR',5);
--UPDATE GR02_JUEGA SET id_juego=101 WHERE id_usuario=100 AND id_juego=22;
--INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (2,17,2,'2020-11-28','prueba 2');
--INSERT INTO GR02_USUARIO(id_usuario, apellido, nombre, email, id_tipo_usuario, password) VALUES(101,'Rodriguez','German','rorro14@gmail.com',20,'LO-MAS')
--INSERT INTO GR02_JUEGA(finalizado, id_usuario, id_juego) VALUES(null,101,101);
--INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (101,101,15,'2020-11-28','prueba 200002');
--INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (101,101,16,'2020-11-30','prueba 200002');
--UPDATE gr02_juega SET id_juego=74 WHERE id_usuario=101 AND id_juego=101;
--DELETE FROM gr02_juega WHERE ID_USUARIO=101 AND ID_JUEGO=74;


--FALLA
--UPDATE GR02_JUEGA SET id_juego=56 WHERE id_usuario=160 AND id_juego=23; NO HACE NADA PORQUE NO ESE JUGADOR NO JUEGA ESE JUEGO
--INSERT INTO gr02_comenta(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (1,74,'2020-05-23','2020-07-25'); VIOLA LA FK EN COMENTA
--UPDATE gr02_comenta SET id_juego=19 WHERE id_usuario=2 AND id_juego=17; NO HA JUGADO


--C) 1- Se debe mantener sincronizadas las tablas COMENTA y COMENTARIO en los siguientes aspectos:
CREATE OR REPLACE FUNCTION FN_GR02_SINCRONIZACION_COMENTA_COMENTARIO()
RETURNS Trigger AS
$$
    DECLARE
        fechadelcomentario timestamp;
        primerfecha timestamp;
        ultimafecha timestamp;
        cantidad_comentarios INTEGER;
    BEGIN
        SELECT fecha_comentario into fechadelcomentario
        FROM gr02_comentario
        WHERE id_usuario=NEW.id_usuario AND id_juego=NEW.id_juego;

        SELECT fecha_primer_com  INTO primerfecha
        FROM GR02_COMENTA
        WHERE id_usuario=NEW.id_usuario AND id_juego=NEW.id_juego;

        SELECT fecha_ultimo_com INTO ultimafecha
        FROM GR02_COMENTA
        WHERE id_usuario=NEW.id_usuario AND id_juego=NEW.id_juego;

        SELECT COUNT(*) INTO cantidad_comentarios
        FROM gr02_comentario
        WHERE id_usuario=NEW.id_usuario AND id_juego=NEW.id_juego;

        IF (cantidad_comentarios<1)THEN
            INSERT INTO GR02_COMENTA (id_usuario,id_juego, fecha_primer_com, fecha_ultimo_com)
                values (NEW.id_usuario, NEW.id_juego, NEW.fecha_comentario, NULL);
        ELSE IF ((ultimafecha is null) or (ultimafecha is not null)) THEN
            UPDATE GR02_COMENTA SET fecha_ultimo_com=NEW.fecha_comentario WHERE id_usuario=new.id_usuario AND id_juego=new.id_juego;
        END IF;
        END IF;
RETURN NEW;
END
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER TR_GR02_SINCRONIZACION_COMENTA_COMENTARIO
BEFORE INSERT OR UPDATE OF fecha_comentario
ON GR02_COMENTARIO
FOR EACH ROW
EXECUTE PROCEDURE FN_GR02_SINCRONIZACION_COMENTA_COMENTARIO();

--INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (35,13,5,'2020-11-29','Esperancito');
--INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (90,58,6,'2020-11-30','Dia de ñoquis');
--INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (90,58,7,'2020-12-31','Dia de ñoquis pasados');
--UPDATE gr02_comentario set fecha_comentario='2021-1-1-' where id_usuario=90 and id_juego=58 and id_comentario=7;
--DELETE from gr02_comenta where id_usuario=90 and id_juego=58

--C) 2- Dado un patrón de búsqueda devolver todos los datos de el o los usuarios
-- junto con la cantidad de juegos que ha jugado y la cantidad de votos que ha realizado.

CREATE TABLE GR02_PATRON_BUSQUEDA_USUARIOS(
    id_usuario int  NOT NULL,
    apellido varchar(50)  NOT NULL,
    nombre varchar(50)  NOT NULL,
    email varchar(30)  NOT NULL,
    id_tipo_usuario int  NOT NULL,
    password varchar(32)  NOT NULL,
    cantidad_votos int NOT NULL,
    cantidad_juegos_jugados int NOT NULL,
    CONSTRAINT PK_GR02_USUARIO PRIMARY KEY (id_usuario)
);

create or replace function FN_GR02_PATRON_BUSQUEDA (Nro_usuario int)
   returns GR02_PATRON_BUSQUEDA_USUARIOS as
$$
declare
    cant_votos integer;
    cant_juegos integer;
begin


       RETURN QUERY SELECT u.id_usuario,u.apellido,u.nombre,u.email,u.id_tipo_usuario,u.password, COUNT(*) INTO cant_votos,COUNT(*) INTO cant_juegos
            FROM gr02_usuario u JOIN gr02_voto g02v on (u.id_usuario = g02v.id_usuario)
                                JOIN gr02_juega g02j on (u.id_usuario = g02j.id_usuario)
            WHERE u.id_usuario = Nro_usuario;
end;
$$
language 'plpgsql';

select FN_GR02_PATRON_BUSQUEDA(13);


--D. DEFINICIÓN DE VISTAS
--1. COMENTARIOS_MES: Listar todos los comentarios realizados durante el último mes descartando aquellos juegos de la Categoría “Sin Categorías”.

CREATE VIEW GR02_COMENTARIOS_MES AS
SELECT com.*
FROM gr02_comentario com
WHERE (fecha_comentario >= NOW() - interval '1 month')
    AND (com.id_usuario , com.id_juego) IN (
    SELECT c.id_usuario, c.id_juego
    FROM gr02_comenta c
    where c.id_juego IN (
        SELECT j.id_juego
        FROM gr02_juego j
        WHERE j.id_categoria IN (
            SELECT id_categoria
            FROM gr02_categoria
            WHERE descripcion NOT LIKE '%sin categoria%'
        )
    )
);

--2. USUARIOS_COMENTADORES: Listar aquellos usuarios que han comentado TODOS los juegos durante el último año,
-- teniendo en cuenta que sólo pueden comentar aquellos juegos que han jugado.

CREATE VIEW GR02_USUARIOS_COMENTADORES AS
SELECT u.*
FROM gr02_usuario u
where u.id_usuario IN(
    SELECT com.id_usuario
    FROM gr02_comentario c JOIN gr02_comenta com ON (c.id_usuario=com.id_usuario)
                JOIN gr02_usuario u ON (u.id_usuario=com.id_usuario)
                JOIN gr02_juega j on (u.id_usuario = j.id_usuario)
    WHERE (com.fecha_ultimo_com >= NOW() - interval '1 year')
    GROUP BY com.id_usuario
    HAVING COUNT(com.id_juego)=COUNT(j.id_juego));

--3. LOS_20_JUEGOS_MAS_PUNTUADOS: Realizar el ranking de los 20 juegos mejor puntuados por los Usuarios.
--El ranking debe ser generado considerando el promedio del valor puntuado por los usuarios y que el juego hubiera sido calificado más de 5 veces.

CREATE VIEW GR02_LOS_20_JUEGOS_MAS_PUNTUADOS AS
SELECT j.id_juego, j.nombre_juego
FROM gr02_juego j
WHERE j.id_juego  IN (
    SELECT id_juego
    FROM gr02_voto
    GROUP BY id_juego
    HAVING COUNT(*)>= 5
    ORDER BY AVG(valor_voto) desc)
LIMIT 20;

--4. LOS_10_JUEGOS_MAS_JUGADOS: Generar una vista con los 10 juegos más jugados.

CREATE VIEW GR02_LOS_10_JUEGOS_MAS_JUGADOS AS
SELECT id_juego, COUNT(id_usuario) as cantidaddejugadores
FROM gr02_juega
GROUP BY id_juego
ORDER BY COUNT(id_juego) DESC
LIMIT 10;

