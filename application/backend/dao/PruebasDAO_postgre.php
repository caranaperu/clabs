<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las unidades de medida.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: PruebasDAO_postgre.php 204 2014-06-23 22:44:25Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:44:25 -0500 (lun, 23 jun 2014) $
 * $Rev: 204 $
 */
class PruebasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct($activeSearchOnly);
    }

    /**
     * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return 'select * from ( select sp_pruebas_delete_record(\'' . $id . '\',null,' . $versionId . ')  as updins) as ans where updins is not null';
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  PruebasModel  */

        $sql = 'select sp_pruebas_save_record(' .
                '\'' . $record->get_pruebas_codigo() . '\'::character varying,' .
                '\'' . $record->get_pruebas_descripcion() . '\'::character varying,' .
                '\'' . $record->get_pruebas_generica_codigo() . '\'::character varying,' .
                '\'' . $record->get_categorias_codigo() . '\'::character varying,' .
                '\'' . $record->get_pruebas_sexo() . '\'::character,' .
                '\'' . $record->get_pruebas_record_hasta() . '\'::character varying,' .
                '\'' . $record->get_pruebas_anotaciones() . '\'::character varying,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer, 0::BIT)';
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {

        if ($subOperation == 'fetchJoined') {
            $sql = 'select pruebas_codigo,pruebas_descripcion,pruebas_generica_codigo,cla.pruebas_clasificacion_descripcion,pr.categorias_codigo,cat.categorias_descripcion,pruebas_sexo,' .
                    'pruebas_record_hasta,pruebas_anotaciones,pg.apppruebas_multiple,pruebas_protected,pr.activo,pr.xmin as "versionId" from  tb_pruebas pr ' .
                    'inner join tb_categorias cat on pr.categorias_codigo = cat.categorias_codigo ' .
                    'inner join tb_app_pruebas_values pg on pg.apppruebas_codigo = pr.pruebas_generica_codigo ' .
                    'inner join tb_pruebas_clasificacion cla on pg.pruebas_clasificacion_codigo = cla.pruebas_clasificacion_codigo ';
        } else if ($subOperation == 'fetchJoinedFull') {
            $sql = 'select pruebas_codigo,pruebas_descripcion,pruebas_sexo,pr.categorias_codigo,categorias_descripcion,pg.apppruebas_marca_menor,pg.apppruebas_marca_mayor,apppruebas_multiple,' .
                    'apppruebas_verifica_viento,unidad_medida_regex_e,unidad_medida_regex_m,unidad_medida_tipo,pc.unidad_medida_codigo,pr.activo,pr.xmin as "versionId" '
                    . ' from tb_pruebas pr ' .
                    'inner join tb_app_pruebas_values pg on pg.apppruebas_codigo= pr.pruebas_generica_codigo ' .
                    'inner join tb_pruebas_clasificacion pc on pc.pruebas_clasificacion_codigo = pg.pruebas_clasificacion_codigo ' .
                    'inner join tb_unidad_medida um on um.unidad_medida_codigo=pc.unidad_medida_codigo ' .
                    'inner join tb_categorias cat on cat.categorias_codigo = pr.categorias_codigo ' ;
        } else {
            $sql = 'select pruebas_codigo,pruebas_descripcion,pruebas_generica_codigo,categorias_codigo,pruebas_sexo,' .
                    'pruebas_record_hasta,pruebas_anotaciones,pruebas_protected,activo,xmin as "versionId" from  tb_pruebas pr';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where pr.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();

        if (strlen($where) > 0) {
            if ($this->activeSearchOnly == TRUE) {
                $sql .= ' and ' . $where;
            } else {
                $sql .= ' where ' . $where;
            }
        }

        // Para la sub operacion fetchJoinedFull acotamos que no se presenten la pruebas que pertenecen
        // a combinadas , ya que estan no pueden ser agregadas independientemente a un resultado.
        // Asi mismo no mostramos las postas ya que no se soporta operaciones sobre ellas en este DAO
        // eso debe hacerse por los resultados de competencias/pruebas.
        if ($subOperation == 'fetchJoinedFull') {
            // ya existe where
            if (strpos($sql,'where') !== false) {
                $sql = str_replace('where', 'where apppruebas_nro_atletas <= 1 and pr.pruebas_codigo not in (select pruebas_detalle_prueba_codigo from tb_pruebas_detalle) and ', $sql);

            } else {
                $sql .= ' where apppruebas_nro_atletas <= 1 and pr.pruebas_codigo not in (select pruebas_detalle_prueba_codigo from tb_pruebas_detalle)';
            }
        }
 //       echo $sql;

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

        $sql = str_replace('"categorias_codigo"', 'pr.categorias_codigo', $sql);
        $sql = str_replace('like', 'ilike', $sql);
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
        return 'select pruebas_codigo,pruebas_descripcion,pruebas_generica_codigo,categorias_codigo,pruebas_sexo,' .
                'pruebas_record_hasta,pruebas_anotaciones,activo,pruebas_protected,' .
                'xmin as "versionId" from tb_pruebas where "pruebas_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  PruebasModel  */
//        return 'update tb_pruebas set pruebas_codigo=\'' . $record->get_pruebas_codigo() . '\',' .
//                'pruebas_descripcion=\'' . $record->get_pruebas_descripcion() . '\',' .
//                'pruebas_clasificacion=\'' . $record->get_pruebas_clasificacion_codigo() . '\',' .
//                'categorias_codigo=\'' . $record->get_categorias_codigo() . '\',' .
//                'pruebas_sexo=\'' . $record->get_pruebas_sexo() . '\',' .
//                'pruebas_record_hasta=\'' . $record->get_pruebas_record_hasta() . '\',' .
//                'pruebas_anotaciones=\'' . $record->get_pruebas_anotaciones() . '\',' .
//                'pruebas_multiple=\'' . $record->get_pruebas_multiple() . '\',' .
//                'activo=\'' . $record->getActivo() . '\',' .
//                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
//                ' where "pruebas_codigo" = \'' . $record->get_pruebas_codigo() . '\'  and xmin =' . $record->getVersionId();

        $sql = 'select * from (select  sp_pruebas_save_record(' .
                '\'' . $record->get_pruebas_codigo() . '\'::character varying,' .
                '\'' . $record->get_pruebas_descripcion() . '\'::character varying,' .
                '\'' . $record->get_pruebas_generica_codigo() . '\'::character varying,' .
                '\'' . $record->get_categorias_codigo() . '\'::character varying,' .
                '\'' . $record->get_pruebas_sexo() . '\'::character,' .
                '\'' . $record->get_pruebas_record_hasta() . '\'::character varying,' .
                '\'' . $record->get_pruebas_anotaciones() . '\'::character varying,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->get_Usuario_mod() . '\'::character varying,' .
                $record->getVersionId() . '::integer, 1::BIT) as insupd) as ans where insupd is not null;';

        return $sql;
    }

}

?>