<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los usuarios
 *
 * @author  $Author: aranape@gmail.com $
 * @since   06-FEB-2013
 * @version $Id: UsuariosDAO_postgre.php 57 2015-08-23 22:46:22Z aranape@gmail.com $
 * @history ''
 *
 * $Date: 2015-08-23 17:46:22 -0500 (dom, 23 ago 2015) $
 * $Rev: 57 $
 */
class UsuariosDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * No usable en este caso siempre sera false
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct(false);
    }

    /**
     * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return 'delete from tb_usuarios where usuarios_id = ' . $id . '  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  UsuariosModel  */
        return 'insert into tb_usuarios (usuarios_code,usuarios_password,usuarios_nombre_completo,usuarios_admin,activo,usuario) values(\''.
                $record->get_usuarios_code() . '\',\'' .
                $record->get_usuarios_password() . '\',\'' .
                $record->get_usuarios_nombre_completo() . '\',\'' .
                ($record->get_usuarios_admin() != TRUE ? '0' : '1') .  '\',\'' .
                ($record->getActivo() != TRUE ? '0' : '1') . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        $sql = 'select usuarios_id,usuarios_code,usuarios_password,usuarios_nombre_completo,usuarios_admin,activo,xmin as "versionId" from  tb_usuarios c';

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

        $sql = str_replace('like', 'ilike', $sql);
//echo $sql;
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQuery()
     */
    protected function getRecordQuery($id, $subOperation = NULL) {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id, $subOperation);
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQueryByCode()
     */
    protected function getRecordQueryByCode($code, $subOperation = NULL) {
        return 'select usuarios_id,usuarios_code,usuarios_password,usuarios_nombre_completo,usuarios_admin,activo,xmin as "versionId" from tb_usuarios '
                . 'where usuarios_id =  ' . $code;
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  UsuariosModel  */
        return 'update tb_usuarios set usuarios_code=\'' . $record->get_usuarios_code() . '\',' .
                'usuarios_password=\''.$record->get_usuarios_password(). '\',' .
                'usuarios_nombre_completo=\''.$record->get_usuarios_nombre_completo(). '\',' .
                'usuarios_admin=\''.($record->get_usuarios_admin() != TRUE ? '0' : '1') . '\',' .
                'activo=\'' . ($record->getActivo() != TRUE ? '0' : '1') . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "usuarios_id" = ' . $record->get_usuarios_id() . '  and xmin =' . $record->getVersionId();
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
        return 'SELECT currval(\'tb_usuarios_usuarios_id_seq\')';
    }

}

?>