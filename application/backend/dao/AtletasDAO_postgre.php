<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Este DAO es especifico el mantenimiento de los atletas.
     *
     * @author  $Author: aranape $
     * @since   06-FEB-2013
     * @version $Id: AtletasDAO_postgre.php 305 2014-07-16 02:14:00Z aranape $
     * @history ''
     *
     * $Date: 2014-07-15 21:14:00 -0500 (mar, 15 jul 2014) $
     * $Rev: 305 $
     */
    class AtletasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

        /**
         * Constructor se puede indicar si las busquedas solo seran en registros activos.
         *
         * @param boolean $activeSearchOnly
         */
        public function __construct($activeSearchOnly = TRUE) {
            parent::__construct($activeSearchOnly);
        }

        /**
         * {@inheritdoc}
         * @see TSLBasicRecordDAO::getDeleteRecordQuery()
         */
        protected function getDeleteRecordQuery($id, $versionId) {
            return 'DELETE FROM tb_atletas WHERE atletas_codigo = \'' . $id . '\'  AND xmin =' . $versionId;
        }

        /**
         * @see TSLBasicRecordDAO::getAddRecordQuery()
         */
        protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
            /* @var $record  AtletasModel */

            $sql = 'select sp_atletas_save_record(' .
                '\'' . $record->get_atletas_codigo() . '\'::character varying,' .
                '\'' . $record->get_atletas_ap_paterno() . '\'::character varying,' .
                '\'' . $record->get_atletas_ap_materno() . '\'::character varying,' .
                '\'' . $record->get_atletas_nombres() . '\'::character varying,' .
                '\'' . $record->get_atletas_sexo() . '\'::character,' .
                '\'' . $record->get_atletas_nro_documento() . '\'::character varying,' .
                '\'' . $record->get_atletas_nro_pasaporte() . '\'::character varying,' .
                '\'' . $record->get_paises_codigo() . '\'::character varying,' .
                '\'' . $record->get_atletas_fecha_nacimiento() . '\'::date,' .
                '\'' . $record->get_atletas_telefono_casa() . '\'::character varying,' .
                '\'' . $record->get_atletas_telefono_celular() . '\'::character varying,' .
                '\'' . $record->get_atletas_email() . '\'::character varying,' .
                '\'' . $record->get_atletas_direccion() . '\'::character varying,' .
                '\'' . $record->get_atletas_observaciones() . '\'::character varying,' .
                '\'' . $record->get_atletas_talla_ropa_buzo() . '\'::character varying,' .
                '\'' . $record->get_atletas_talla_ropa_poloshort() . '\'::character varying,' .
                ($record->get_atletas_talla_zapatillas() == '' ? 'NULL' : ('\'' . $record->get_atletas_talla_zapatillas()) . '\'') . '::numeric,' .
                '\'' . $record->get_atletas_norma_zapatillas() . '\'::character varying,' .
                '\'' . $record->get_atletas_url_foto() . '\'::character varying,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer, 0::BIT)';

            return $sql;
        }

        /**
         * @see TSLBasicRecordDAO::getFetchQuery()
         */
        protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
            if ($subOperation == 'fetchForList') {
                // USamos un campo virtual que es atletas_agno el cual es computado , por ende se usa un select
                /// extermo para que el where lo pueda usar.
                $sql = 'select atletas_codigo ,atletas_nombre_completo,atletas_sexo,' .
                    'paises_codigo from  tb_atletas a';
            } else if ($subOperation == 'fetchForListByPosta') {
                // USamos un campo virtual que es atletas_agno el cual es computado , por ende se usa un select
                /// extermo para que el where lo pueda usar.
                $atletas_codigo = $constraints->getFilterField('atletas_codigo');
                if ($atletas_codigo) {
                    $where = $constraints->getFilterFieldsAsString();

                    $sql = 'SELECT
                          a.atletas_codigo,
                          a.atletas_nombre_completo
                        FROM tb_atletas a ';

                    if (strlen($where) > 0) {
                        $sql .= ' where ' . $where;
                    }
                } else {
                    $sql = 'SELECT
                          a.atletas_codigo,
                          a.atletas_nombre_completo
                        FROM tb_atletas a
                        WHERE atletas_sexo = (SELECT pr.pruebas_sexo
                                              FROM tb_postas ps
                                                INNER JOIN tb_competencias_pruebas cp ON cp.competencias_pruebas_id = ps.competencias_pruebas_id
                                                INNER JOIN tb_pruebas pr ON pr.pruebas_codigo = cp.pruebas_codigo
                                                WHERE ps.postas_id = ' . $constraints->getFilterField('postas_id') . ')  ';

                    $constraints->removeFilterField('postas_id');
                    $where = $constraints->getFilterFieldsAsString();

                    if (strlen($where) > 0) {
                        $sql .= ' and ' . $where . ' and a.atletas_protected=FALSE ';
                    } else {
                        $sql .= 'and a.atletas_protected=FALSE ';
                    }


                }
            } else if ($subOperation == 'fetchForListByPrueba') {
                // USamos un campo virtual que es atletas_agno el cual es computado , por ende se usa un select
                /// extermo para que el where lo pueda usar.
                $sql = 'SELECT DISTINCT
                          CASE WHEN ar.postas_id IS  NULL
                            THEN  a.atletas_codigo
                            ELSE pd.atletas_codigo
                            END AS atletas_codigo,
                          CASE WHEN ar.postas_id IS NOT  NULL
                            THEN  (SELECT atletas_nombre_completo FROM tb_atletas WHERE atletas_codigo = pd.atletas_codigo)
                          ELSE atletas_nombre_completo
                          END AS atletas_nombre_completo
                        FROM tb_atletas a
                          INNER JOIN tb_atletas_resultados ar ON ar.atletas_codigo = a.atletas_codigo
                          INNER JOIN tb_competencias_pruebas cp ON cp.competencias_pruebas_id = ar.competencias_pruebas_id
                          INNER JOIN tb_pruebas pc ON pc.pruebas_codigo = cp.pruebas_codigo
                          LEFT  JOIN tb_postas po ON po.competencias_pruebas_id = cp.competencias_pruebas_id AND po.postas_id = ar.postas_id
                          LEFT JOIN  tb_postas_detalle pd ON pd.postas_id = ar.postas_id ';
            } else if ($subOperation == 'fetchForListByPruebaGenerica') {
                $sql = 'SELECT DISTINCT
                          -- IMPORTANTE , si es una posta dado que no existe un unico codigo de atleta
                          -- lo simulamos con el concatenado ordenado de los codigos de los atletas de las postas.
                          -- Si se desea ubicar a una posta DEBERA ENVIARSE el valor de atletas_resultados_id del resultado
                          -- si no la respuesta sera incorrecta.
                          (CASE WHEN ar.postas_id IS NOT NULL
                            THEN
                              (SELECT array_to_string(ARRAY(SELECT unnest(array_agg(atl.atletas_codigo))
                                                            ORDER BY 1), \',\')
                               FROM tb_postas_detalle pd
                                 INNER JOIN tb_postas po ON po.postas_id = pd.postas_id
                                 INNER JOIN tb_atletas atl ON atl.atletas_codigo = pd.atletas_codigo
                               WHERE pd.postas_id = ar.postas_id
                               GROUP BY pd.postas_id)
                           ELSE
                             a.atletas_codigo
                           END) AS atletas_codigo,
                          (CASE WHEN ar.postas_id IS NOT NULL
                            THEN
                              (SELECT array_to_string(ARRAY(SELECT unnest(array_agg(atl.atletas_ap_paterno))
                                                            ORDER BY 1), \',\')
                               FROM tb_postas_detalle pd
                                 INNER JOIN tb_postas po ON po.postas_id = pd.postas_id
                                 INNER JOIN tb_atletas atl ON atl.atletas_codigo = pd.atletas_codigo
                               WHERE pd.postas_id = ar.postas_id
                               GROUP BY pd.postas_id)
                           ELSE
                             atletas_nombre_completo
                           END) AS atletas_nombre_completo
                        FROM tb_atletas a
                          INNER JOIN tb_atletas_resultados ar ON ar.atletas_codigo = a.atletas_codigo
                          INNER JOIN tb_competencias_pruebas cp ON cp.competencias_pruebas_id = ar.competencias_pruebas_id
                          INNER JOIN tb_pruebas pc ON pc.pruebas_codigo = cp.pruebas_codigo
                          INNER JOIN tb_app_pruebas_values pv ON pv.apppruebas_codigo = pc.pruebas_generica_codigo';
            } else if ($subOperation == 'fetchForListForResultados') {
                $sql = 'SELECT *  FROM (SELECT atletas_codigo ,atletas_nombre_completo,atletas_sexo,activo 
                        FROM  tb_atletas
                        WHERE atletas_protected != TRUE ) a';
            } else {
                // USamos un campo virtual que es atletas_agno el cual es computado , por ende se usa un select
                /// extermo para que el where lo pueda usar.
                $sql = 'SELECT *  FROM (SELECT atletas_codigo ,atletas_ap_paterno ,atletas_ap_materno,atletas_nombres,atletas_nombre_completo,atletas_sexo,' .
                    'atletas_nro_documento,atletas_nro_pasaporte,paises_codigo,atletas_fecha_nacimiento,EXTRACT(YEAR FROM atletas_fecha_nacimiento)::CHARACTER VARYING AS atletas_agno,atletas_telefono_casa,' .
                    'atletas_telefono_celular,atletas_email,atletas_direccion,atletas_observaciones,atletas_talla_ropa_buzo,atletas_talla_ropa_poloshort,atletas_talla_zapatillas,atletas_norma_zapatillas,' .
                    'atletas_url_foto,atletas_protected,activo,xmin AS "versionId" FROM  tb_atletas 
                    WHERE atletas_protected != TRUE) a';
            }

            if ($this->activeSearchOnly == TRUE) {
                // Solo activos
                if ($subOperation == 'fetchForListByPosta') {
                    $sql .= ' and a.activo=TRUE ';
                } else {
                    $sql .= ' where a.activo=TRUE ';
                }
            }

            if ($subOperation !== 'fetchForListByPosta') {
                $where = $constraints->getFilterFieldsAsString();
                if (strlen($where) > 0) {
                    if ($this->activeSearchOnly == TRUE) {
                        $sql .= ' and ' . $where;
                    } else {
                        $sql .= ' where ' . $where;
                    }
                }
            }

            if (isset($constraints)) {
                $orderby = $constraints->getSortFieldsAsString();
                if ($orderby !== NULL) {
                    $sql .= ' order by ' . $orderby;
                }
            }

            $sql = str_replace('"atletas_codigo"', 'a.atletas_codigo', $sql);

            // Chequeamos paginacion
            $startRow = $constraints->getStartRow();
            $endRow = $constraints->getEndRow();

            if ($endRow > $startRow) {
                $sql .= ' LIMIT ' . ($endRow - $startRow) . ' OFFSET ' . $startRow;
            }

            $sql = str_replace('like', 'ilike', $sql);

           // echo $sql;

            return $sql;
        }

        /**
         * @see TSLBasicRecordDAO::getRecordQuery()
         */
        protected function getRecordQuery($id) {
            // en este caso el codigo es la llave primaria
            return $this->getRecordQueryByCode($id);
        }

        /**
         * @see TSLBasicRecordDAO::getRecordQueryByCode()
         */
        protected function getRecordQueryByCode($code) {
            return 'select atletas_codigo ,atletas_ap_paterno ,atletas_ap_materno,atletas_nombres,atletas_nombre_completo,atletas_sexo,' .
            'atletas_nro_documento,atletas_nro_pasaporte,paises_codigo,atletas_fecha_nacimiento,EXTRACT(YEAR FROM atletas_fecha_nacimiento)::CHARACTER VARYING as atletas_agno,atletas_telefono_casa,' .
            'atletas_telefono_celular,atletas_email,atletas_direccion,atletas_observaciones,atletas_talla_ropa_buzo,atletas_talla_ropa_poloshort,' .
            'atletas_talla_zapatillas,atletas_norma_zapatillas,atletas_url_foto,activo,' .
            'xmin as "versionId" from tb_atletas where atletas_codigo =  \'' . $code . '\'';
        }

        /**
         * Aqui el id es el codigo
         * @see TSLBasicRecordDAO::getUpdateRecordQuery()
         */
        protected function getUpdateRecordQuery(\TSLDataModel &$record) {
            /* @var $record  AtletasModel */
            $sql = 'SELECT * FROM (SELECT sp_atletas_save_record(' .
                '\'' . $record->get_atletas_codigo() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_ap_paterno() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_ap_materno() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_nombres() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_sexo() . '\'::CHARACTER,' .
                '\'' . $record->get_atletas_nro_documento() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_nro_pasaporte() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_paises_codigo() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_fecha_nacimiento() . '\'::DATE,' .
                '\'' . $record->get_atletas_telefono_casa() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_telefono_celular() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_email() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_direccion() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_observaciones() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_talla_ropa_buzo() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_talla_ropa_poloshort() . '\'::CHARACTER VARYING,' .
                ($record->get_atletas_talla_zapatillas() == '' ? 'NULL' : ('\'' . $record->get_atletas_talla_zapatillas()) . '\'') . '::NUMERIC,' .
                '\'' . $record->get_atletas_norma_zapatillas() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_atletas_url_foto() . '\'::CHARACTER VARYING,' .
                '\'' . $record->getActivo() . '\'::BOOLEAN,' .
                '\'' . $record->get_Usuario_mod() . '\'::CHARACTER VARYING,' .
                $record->getVersionId() . '::INTEGER, 1::BIT) AS insupd) AS ans WHERE insupd IS NOT NULL;';
            echo $sql;

            return $sql;
        }

    }

?>