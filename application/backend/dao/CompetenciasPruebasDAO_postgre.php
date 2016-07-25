<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico para el mantenimiento de resultados de pruebas
 * directamente ingresadas al atleta.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: CompetenciasPruebasDAO_postgre.php 209 2014-06-23 22:48:51Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:48:51 -0500 (lun, 23 jun 2014) $
 * $Rev: 209 $
 */
class CompetenciasPruebasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct(FALSE); // se permite siempre la busqueda incluyendo activos o no.
    }

    /**
     * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return 'select * from ( select sp_competencias_pruebas_delete_record( ' . $id . '::integer,null::character varying,' . $versionId . '::integer)  as updins) as ans where updins is not null';
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  CompetenciasPruebasModel  */
        $sql = 'select sp_competencias_pruebas_save_record(' .
                'null::integer,' .
                '\'' . $record->get_competencias_codigo() . '\'::character varying,' .
                '\'' . $record->get_pruebas_codigo() . '\'::character varying,' .
                ($record->get_competencias_pruebas_origen_id() == null ? 'null' : $record->get_competencias_pruebas_origen_id()) . '::integer,' .
                '\'' . $record->get_competencias_pruebas_fecha() . '\'::date,' .
                ($record->get_competencias_pruebas_viento() == null ? 'null' : $record->get_competencias_pruebas_viento()) . '::numeric ,' .
                '\'' . $record->get_competencias_pruebas_manual() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_tipo_serie() . '\'::character varying,' .
                ($record->get_competencias_pruebas_nro_serie() == null ? '1' : $record->get_competencias_pruebas_nro_serie()) . '::integer ,' .
                '\'' . $record->get_competencias_pruebas_anemometro() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_material_reglamentario() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_observaciones() . '\'::character varying,' .
                '\'false\'::boolean,' . //  protected
                '\'true\'::boolean,' . //  protected
                '\'true\'::boolean,' . //  protected
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer, 0::BIT)';
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        /* @var $record  CompetenciasPruebasModel  */

        if ($subOperation == 'fetchPruebasPorCompetencia') {
            // Aqui solo se devolveran las pruebas genericas que componen una competencia , por ende
            // se espera coo parametro el codigo de competencia, es similar a la anterior pero esperando diferente
            // parametro , las separa por comodidad. La lista solo contendra las pruebas ya actualmente
            // definidas como parte de la competencia
            $where = $constraints->getFilterFieldsAsString();

            $sql = 'select  cp.competencias_pruebas_id,cp.competencias_codigo,
                        pr.pruebas_codigo,
                        cp.competencias_pruebas_fecha,cp.competencias_pruebas_viento,cp.competencias_pruebas_manual,
                        cp.competencias_pruebas_origen_combinada,
                        cp.competencias_pruebas_tipo_serie,cp.competencias_pruebas_nro_serie,cp.competencias_pruebas_anemometro,
                        cp.competencias_pruebas_material_reglamentario,
                        cp.competencias_pruebas_observaciones,
                        pr.pruebas_generica_codigo,
                        pv.apppruebas_descripcion,
                        pr.pruebas_descripcion || \' (\' || (case when pruebas_sexo = \'F\' then \'Damas\' else \'Varones\' end) || \')\' as pruebas_descripcion,
                        pv.apppruebas_multiple,
                        (case when cp.competencias_pruebas_tipo_serie IN (\'SU\',\'FI\')  then cp.competencias_pruebas_tipo_serie else (cp.competencias_pruebas_tipo_serie || \'-\' || cp.competencias_pruebas_nro_serie) end) as serie,
                        cp.competencias_pruebas_origen_id,pruebas_sexo,cp.xmin as "versionId"
                 from  tb_competencias_pruebas cp
                            inner join tb_pruebas pr on pr.pruebas_codigo = cp.pruebas_codigo
                            inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo
                            where ' . str_replace('"competencias_', 'cp."competencias_', $where) .
                    'order by pruebas_sexo,apppruebas_descripcion,cp.competencias_pruebas_tipo_serie,cp.competencias_pruebas_nro_serie';
        } else {
            if ($subOperation == 'fetchCompetenciasResultadoPrueba') {
                // Devuelve los datos de una tleta para una especifica prueba , si la prueba es null retornara todos
                // sus resultados.
                $sql = 'select * from  sp_view_resultados_competencia_especifica(\'' . $constraints->getFilterField('competencias_codigo') . '\',\'' .
                        $constraints->getFilterField('pruebas_codigo') . '\',\'' . $constraints->getFilterField('pruebas_sexo') . '\',null,null) ';
                $constraints->removeFilterField('pruebas_codigo');
                $constraints->removeFilterField('competencias_codigo');
                $constraints->removeFilterField('pruebas_sexo');
               // echo $sql;
            } else if ($subOperation == 'fetchPruebasValidasForCompetencia') {
                // Lista de todas las competencias posibles de crear para una determinada competencia esten creadas o no, por la
                // posibilidad que se requiere crear series o grupos, Si una combinada es parte ya de la competencia , no
                // aparecera en esta lista, ya que no se puede definir 2 veces.
                //
                // El query busca todas las posibles pruebas para la categoria de la competencia , menos la combinadas ya definidasd
                // Devuelve informacion complemnetaria de las pruebas para su posible trabajo/validacion en el lado solicitante.
                $sql = 'select * from (
                        select
                        pruebas_codigo,pruebas_descripcion || \' (\' || (case when pruebas_sexo = \'F\' then \'Damas\' else \'Varones\' end) || \')\' as pruebas_descripcion,
                        pruebas_generica_codigo,
                        pr.categorias_codigo,
                        pruebas_sexo,
                        pg.apppruebas_multiple,
                        pg.apppruebas_verifica_viento,
                        pg.apppruebas_descripcion,
                        pg.apppruebas_viento_individual,
                        pg.apppruebas_nro_atletas,
                        unidad_medida_tipo,
                        unidad_medida_regex_e,
                        unidad_medida_regex_m,
                        (SELECT competencias_pruebas_id
FROM tb_competencias_pruebas where pruebas_codigo =
	(select pruebas_codigo from tb_pruebas_detalle where pruebas_detalle_prueba_codigo=pr.pruebas_codigo) and
        competencias_codigo=\''.$constraints->getFilterField('competencias_codigo').'\') as competencias_pruebas_origen_id
                        from  tb_pruebas pr
                        inner join tb_app_pruebas_values pg on pg.apppruebas_codigo = pr.pruebas_generica_codigo
                        inner join tb_pruebas_clasificacion pc on pc.pruebas_clasificacion_codigo = pg.pruebas_clasificacion_codigo
                        inner join tb_unidad_medida um on um.unidad_medida_codigo = pc.unidad_medida_codigo
                        where pr.categorias_codigo = (select categorias_codigo from tb_competencias where competencias_codigo=\'' . $constraints->getFilterField('competencias_codigo') . '\')) results ';
                $constraints->removeFilterField('competencias_codigo');
            } else {
                $sql = 'select  cp.competencias_pruebas_id,cp.competencias_codigo,
                        cp.pruebas_codigo,
                        cp.competencias_pruebas_fecha,cp.competencias_pruebas_viento,cp.competencias_pruebas_manual,
                        cp.competencias_pruebas_origen_combinada,
                        cp.competencias_pruebas_tipo_serie,cp.competencias_pruebas_nro_serie,cp.competencias_pruebas_anemometro,
                        cp.competencias_pruebas_material_reglamentario,
                        cp.competencias_pruebas_observaciones,cp.competencias_pruebas_origen_id,
                        competencias_pruebas_origen_combinada,
                        cp.xmin as "versionId"
                 from  tb_competencias_pruebas cp ';
            }

            if ($this->activeSearchOnly == TRUE) {
                // Solo activos
                $sql .= ' where eatl.activo = TRUE ';
            }

            // Que pasa si el campo a buscar existe en ambas partes del join?
            $where = $constraints->getFilterFieldsAsString();
            if (strlen($where) > 0) {
                if ($this->activeSearchOnly == TRUE) {
                    $sql .= ' and ' . $where;
                } else {
                    $sql .= ' where ' . $where;
                }
            }


            if (isset($constraints)) {
                $orderby = $constraints->getSortFieldsAsString();
                if ($orderby !== NULL) {
                    $sql .= ' order by ' . $orderby;
                }
            }

            // Chequeamos paginacion
            $startRow = $constraints->getStartRow();
            $endRow = $constraints->getEndRow();

            if ($endRow > $startRow) {
                $sql .= ' LIMIT ' . ($endRow - $startRow) . ' OFFSET ' . $startRow;
            }
        }
        $sql = str_replace('like', 'ilike', $sql);
        //  echo $sql;
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQuery()
     */
    protected function getRecordQuery($id) {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id);
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQueryByCode()
     */
    protected function getRecordQueryByCode($code) {
        $sql = 'select  cp.competencias_pruebas_id,cp.competencias_codigo,
                        cp.pruebas_codigo,
                        cp.competencias_pruebas_fecha,cp.competencias_pruebas_viento,cp.competencias_pruebas_manual,
                        cp.competencias_pruebas_origen_combinada,
                        cp.competencias_pruebas_tipo_serie,cp.competencias_pruebas_nro_serie,cp.competencias_pruebas_anemometro,
                        cp.competencias_pruebas_material_reglamentario,
                        cp.competencias_pruebas_observaciones,cp.competencias_pruebas_origen_id,
                        competencias_pruebas_origen_combinada,
                        cp.xmin as "versionId"
                 from  tb_competencias_pruebas cp
                            where competencias_pruebas_id=' . $code;
        return $sql;
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {

        /* @var $record  CompetenciasPruebasModel */
            $sql = 'select * from (select sp_competencias_pruebas_save_record(' .
                $record->get_competencias_pruebas_id().'::integer,' .
                '\'' . $record->get_competencias_codigo() . '\'::character varying,' .
                '\'' . $record->get_pruebas_codigo() . '\'::character varying,' .
                ($record->get_competencias_pruebas_origen_id() == null ? 'null' : $record->get_competencias_pruebas_origen_id()) . '::integer,' .
                '\'' . $record->get_competencias_pruebas_fecha() . '\'::date,' .
                ($record->get_competencias_pruebas_viento() == null ? 'null' : $record->get_competencias_pruebas_viento()) . '::numeric ,' .
                '\'' . $record->get_competencias_pruebas_manual() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_tipo_serie() . '\'::character varying,' .
                ($record->get_competencias_pruebas_nro_serie() == null ? '1' : $record->get_competencias_pruebas_nro_serie()) . '::integer ,' .
                '\'' . $record->get_competencias_pruebas_anemometro() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_material_reglamentario() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_observaciones() . '\'::character varying,' .
                '\'false\'::boolean,' . //  protected
                '\'true\'::boolean,' . //  protected
                '\'true\'::boolean,' . //  protected
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->get_Usuario_mod() . '\'::character varying,' .
                $record->getVersionId() . '::integer, 1::BIT)  as insupd) as ans where insupd is not null';
        return $sql;

    }

    /**
     * Este es un caso especial , ya que el stored procedure que inserta , para el caso de las
     * pruebas combinadas , primero agrega el resultado para la principal y luego los de las pruebas
     * que componen la combinada , por esto un simple select al currval no es suficiente , ya que retornaria el id
     * del ultimo resultado agregado , el cual no corresponderia a la cabeza de las pruebas combinadas.
     *
     *
     * @param \TSLDataModel $record
     * @return string
     */
    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
        /* @var $record  CompetenciasPruebasModel */
        $sql = 'select competencias_pruebas_id from tb_competencias_pruebas where competencias_codigo=\'' . $record->get_competencias_codigo() .
                '\' and pruebas_codigo  = \'' . $record->get_pruebas_codigo() .
                '\' and competencias_pruebas_tipo_serie = \'' .
                $record->get_competencias_pruebas_tipo_serie() .
                '\' and  competencias_pruebas_nro_serie=' . $record->get_competencias_pruebas_nro_serie().
                ' and competencias_pruebas_origen_combinada=\''.$record->get_competencias_pruebas_origen_combinada().'\'';
        return $sql;
    }

}

?>