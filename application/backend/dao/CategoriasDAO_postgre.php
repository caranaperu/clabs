<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las categorias
 * atleticas , digase menores,juveniles , mayores.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: CategoriasDAO_postgre.php 206 2014-06-23 22:46:55Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:46:55 -0500 (lun, 23 jun 2014) $
 * $Rev: 206 $
 */
class CategoriasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_categorias where categorias_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  CategoriasModel  */
        return 'insert into tb_categorias (categorias_codigo,categorias_descripcion,categorias_edad_inicial,categorias_edad_final,categorias_valido_desde,' .
                'categorias_validacion,activo,usuario) values(\'' .
                $record->get_categorias_codigo() . '\',\'' .
                $record->get_categorias_descripcion() . '\',' .
                $record->get_categorias_edad_inicial() . ',' .
                $record->get_categorias_edad_final() . ',\'' .
                $record->get_categorias_valido_desde() . '\',\'' .
                $record->get_categorias_validacion() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        if ($subOperation == 'fetchWithPesos') {
            $sql = 'select categorias_codigo,categorias_descripcion,appcat_peso '.
                     'from  tb_categorias c '.
                    'inner join tb_app_categorias_values cv on cv.appcat_codigo = c.categorias_validacion';
        } else {
            $sql = 'select categorias_codigo,categorias_descripcion,categorias_edad_inicial,categorias_edad_final,categorias_valido_desde,' .
                    'categorias_validacion,categorias_protected,activo,xmin as "versionId" from  tb_categorias c';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where c.activo=TRUE ';
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
//echo $sql;
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
        return 'select categorias_codigo,categorias_descripcion,categorias_edad_inicial,categorias_edad_final,categorias_valido_desde,' .
                'categorias_validacion,categorias_protected,activo,' .
                'xmin as "versionId" from tb_categorias where "categorias_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  CategoriasModel  */
        return 'update tb_categorias set categorias_codigo=\'' . $record->get_categorias_codigo() . '\',' .
                'categorias_descripcion=\'' . $record->get_categorias_descripcion() . '\',' .
                'categorias_edad_inicial=' . $record->get_categorias_edad_inicial() . ',' .
                'categorias_edad_final=' . $record->get_categorias_edad_final() . ',' .
                'categorias_valido_desde=\'' . $record->get_categorias_valido_desde() . '\',' .
                'categorias_validacion=\'' . $record->get_categorias_validacion() . '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "categorias_codigo" = \'' . $record->get_categorias_codigo() . '\'  and xmin =' . $record->getVersionId();
    }

}

?>