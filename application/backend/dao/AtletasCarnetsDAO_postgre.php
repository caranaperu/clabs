<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los carnets de campo.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: AtletasCarnetsDAO_postgre.php 208 2014-06-23 22:48:07Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:48:07 -0500 (lun, 23 jun 2014) $
 * $Rev: 208 $
 */
class AtletasCarnetsDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
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
        return 'delete from tb_atletas_carnets where atletas_carnets_id = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  AtletasCarnetsModel  */
        return 'insert into tb_atletas_carnets (atletas_carnets_agno,atletas_carnets_numero,atletas_codigo,atletas_carnets_fecha,' .
                'activo,usuario) values(' .
                $record->get_atletas_carnets_agno() . ',\'' .
                $record->get_atletas_carnets_numero() . '\',\'' .
                $record->get_atletas_codigo() . '\',\'' .
                $record->get_atletas_carnets_fecha() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @see TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos

        if ($subOperation == 'fetchJoined') {
            $sql = 'select atletas_carnets_id,atletas_carnets_agno::CHARACTER VARYING as atletas_carnets_agno,atletas_carnets_numero,catl.atletas_codigo,atletas_nombre_completo,atletas_carnets_fecha,catl.activo,catl.xmin as "versionId" from  tb_atletas_carnets catl '.
                    'inner join tb_atletas atl on catl.atletas_codigo = atl.atletas_codigo ';
        } else {
            $sql = 'select atletas_carnets_id,atletas_carnets_agno::CHARACTER VARYING as atletas_carnets_agno,atletas_carnets_numero,atletas_codigo,atletas_carnets_fecha,activo,xmin as "versionId" from  tb_atletas_carnets catl';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where catl.activo=TRUE ';
        }

        // Que pasa si el campo a buscar existe en ambas partes del join?
        $where = $constraints->getFilterFieldsAsString();
        if ($this->activeSearchOnly == TRUE) {
            if (strlen($where) > 0) {
                $sql .= ' and ' . $where;
            }
        } else {
            $sql .= ' where ' . $where;
        }

        if (isset($constraints)) {
            $orderby = $constraints->getSortFieldsAsString();
            if ($orderby !== NULL) {
                $sql .= ' order by ' . $orderby;
            }
        }

        $sql = str_replace('like', 'ilike', $sql);
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
        return 'select atletas_carnets_id,atletas_carnets_agno,atletas_carnets_numero,atletas_codigo,atletas_carnets_fecha,activo,' .
                'xmin as "versionId" from tb_atletas_carnets where atletas_carnets_id =  ' . $code;
    }

    /**
     * Aqui el id es el codigo
     * @see TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  AtletasCarnetsModel  */
        return 'update tb_atletas_carnets set atletas_carnets_id=' . $record->get_atletas_carnets_id() . ',' .
                'atletas_carnets_agno=' . $record->get_atletas_carnets_agno() . ',' .
                'atletas_carnets_numero=\'' . $record->get_atletas_carnets_numero() . '\',' .
                'atletas_codigo=\'' . $record->get_atletas_codigo() . '\',' .
                'atletas_carnets_fecha=\'' . $record->get_atletas_carnets_fecha() . '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "atletas_carnets_id" = \'' . $record->get_atletas_carnets_id() . '\'  and xmin =' . $record->getVersionId();
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
        return 'SELECT currval(\'tb_atletas_carnets_atletas_carnets_id_seq\')';
    }

}
?>