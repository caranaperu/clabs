<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico del mantenimiento de competencias.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: CompetenciasDAO_postgre.php 298 2014-06-30 23:59:00Z aranape $
 * @history ''
 *
 * $Date: 2014-06-30 18:59:00 -0500 (lun, 30 jun 2014) $
 * $Rev: 298 $
 */
class CompetenciasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct($activeSearchOnly);
    }

    /**
     * {@inheritdoc}
     * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return 'delete from tb_competencias where competencias_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  CompetenciasModel  */
        $sql = 'select sp_competencias_save_record(' .
                '\'' . $record->get_competencias_codigo() . '\'::character varying,' .
                '\'' . $record->get_competencias_descripcion() . '\'::character varying,' .
                '\'' . $record->get_competencia_tipo_codigo() . '\'::character varying,' .
                '\'' . $record->get_categorias_codigo() . '\'::character varying,' .
                '\'' . $record->get_paises_codigo() . '\'::character varying,' .
                '\'' . $record->get_ciudades_codigo() . '\'::character varying,' .
                '\'' . $record->get_competencias_fecha_inicio() . '\'::date,' .
                '\'' . $record->get_competencias_fecha_final() . '\'::date,' .
                '\'' . $record->get_competencias_clasificacion() . '\'::character varying,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer,0::bit)';
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        if ($subOperation == 'fetchJoined') {
            $sql = 'select competencias_codigo,competencias_descripcion,comp.competencia_tipo_codigo,ct.competencia_tipo_descripcion,comp.categorias_codigo,cat.categorias_descripcion,' .
                    'comp.paises_codigo,pais.paises_descripcion,comp.ciudades_codigo,ciu.ciudades_descripcion,ciu.ciudades_altura,EXTRACT(YEAR FROM competencias_fecha_inicio) as agno,competencias_fecha_inicio,competencias_fecha_final,competencias_es_oficial,competencias_clasificacion,comp.activo,comp.xmin as "versionId" from  tb_competencias comp ' .
                    'left join tb_competencia_tipo ct on ct.competencia_tipo_codigo = comp.competencia_tipo_codigo ' .
                    'left join tb_categorias cat on cat.categorias_codigo = comp.categorias_codigo ' .
                    'left join tb_paises pais on pais.paises_codigo = comp.paises_codigo ' .
                    'left join tb_ciudades ciu on ciu.ciudades_codigo = comp.ciudades_codigo ';
        } else {
            $sql = 'select competencias_codigo,competencias_descripcion,comp.competencia_tipo_codigo,comp.categorias_codigo,' .
                    'comp.paises_codigo,comp.ciudades_codigo,competencias_fecha_inicio,competencias_fecha_final,competencias_es_oficial,'
                    . 'competencias_clasificacion,comp.activo,comp.xmin as "versionId" from  tb_competencias comp';
        }


        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where comp.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();
        if (strlen($where) > 0) {
            $sql .= ' and ' . $where;
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
        return 'select competencias_codigo,competencias_descripcion,competencia_tipo_codigo,categorias_codigo,' .
                'paises_codigo,ciudades_codigo,competencias_fecha_inicio,competencias_fecha_final,competencias_es_oficial,competencias_clasificacion,activo,' .
                'xmin as "versionId" from tb_competencias where "competencias_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  CompetenciasModel  */
        $sql = 'select * from (select sp_competencias_save_record(' .
                '\'' . $record->get_competencias_codigo() . '\'::character varying,' .
                '\'' . $record->get_competencias_descripcion() . '\'::character varying,' .
                '\'' . $record->get_competencia_tipo_codigo() . '\'::character varying,' .
                '\'' . $record->get_categorias_codigo() . '\'::character varying,' .
                '\'' . $record->get_paises_codigo() . '\'::character varying,' .
                '\'' . $record->get_ciudades_codigo() . '\'::character varying,' .
                '\'' . $record->get_competencias_fecha_inicio() . '\'::date,' .
                '\'' . $record->get_competencias_fecha_final() . '\'::date,' .
                '\'' . $record->get_competencias_clasificacion() . '\'::character varying,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                $record->getVersionId() . '::integer,1::bit)  as insupd) as ans where insupd is not null;';

        return $sql;
    }

}

?>