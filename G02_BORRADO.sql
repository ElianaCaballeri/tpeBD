DROP TABLE GR02_CATEGORIA CASCADE;
DROP TABLE GR02_COMENTA CASCADE;
DROP TABLE GR02_COMENTARIO CASCADE;
DROP TABLE GR02_JUEGA CASCADE;
DROP TABLE GR02_JUEGO CASCADE;
DROP TABLE GR02_NIVEL CASCADE;
DROP TABLE GR02_RECOMENDACION CASCADE;
DROP TABLE GR02_TIPO_USUARIO CASCADE;
DROP TABLE GR02_USUARIO CASCADE;


DROP FUNCTION TRFN_GR02_fecha_comentario() CASCADE;
DROP TRIGGER TR_GR02_fecha_comentario ON GR02_COMENTARIO CASCADE;

DROP FUNCTION TRFN_GR02_RECOMENDACION_VOTO()  CASCADE;
DROP TRIGGER TR_GR02_RECOMENDACION_VOTO ON GR02_RECOMENDACION CASCADE;

DROP FUNCTION TRFN_GR02_VOTO_RECOMENDACION()  CASCADE;
DROP TRIGGER TR_GR02_VOTO_RECOMENDACION ON GR02_VOTO CASCADE;

DROP FUNCTION TRFN_GR02_COMENTA_FIJA_JUEGA()  CASCADE;
DROP TRIGGER TR_GR02_COMENTA_JUEGA ON GR02_COMENTA CASCADE;

DROP FUNCTION TRFN_GR02_JUEGA_COMENTA_ESTADOCONSISTENTE()  CASCADE;
DROP TRIGGER TR_GR02_JUEGA_COMENTA ON GR02_JUEGA CASCADE;

DROP FUNCTION FN_GR02_SINCRONIZACION_COMENTA_COMENTARIO()  CASCADE;
DROP TRIGGER TR_GR02_SINCRONIZACION_COMENTA_COMENTARIO ON GR02_COMENTARIO CASCADE;

DROP FUNCTION FN_GR02_PATRON_BUSQUEDA ()  CASCADE;

DROP VIEW GR02_COMENTARIOS_MES;
DROP VIEW GR02_USUARIOS_COMENTADORES;
DROP VIEW GR02_LOS_20_JUEGOS_MAS_PUNTUADOS;
DROP VIEW GR02_LOS_10_JUEGOS_MAS_JUGADOS;



































