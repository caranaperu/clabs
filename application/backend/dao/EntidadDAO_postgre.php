<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico para la la definicion de los
 * datos basicos de la entidad , como nombre,dieccion , etc-
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: EntidadDAO_postgre.php 208 2014-06-23 22:48:07Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:48:07 -0500 (lun, 23 jun 2014) $
 * $Rev: 208 $
 */
class EntidadDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_entidad where entidad_id = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record,\TSLRequestConstraints &$constraints=NULL) {
        /**
         * @var EntidadModel $record
         */
        $sql = 'insert into tb_entidad (entidad_razon_social,entidad_ruc,entidad_direccion,' .
                'entidad_telefonos,entidad_fax,entidad_correo,activo,usuario) values(' .
                '\'' . $record->get_entidad_razon_social() . '\',' .
                '\'' . $record->get_entidad_ruc() . '\',' .
                '\'' . $record->get_entidad_direccion() . '\',' .
                '\'' . $record->get_entidad_telefonos() . '\',' .
                '\'' . $record->get_entidad_fax() . '\',' .
                '\'' . $record->get_entidad_correo() . '\',' .
                '\'' . $record->getActivo() . '\',\'' . $record->getUsuario() . '\')';
        return $sql;
    }

    /**
     * Siempre debe devolver un de haber mas de uno , la data habria
     * sido manipulada externamente.
     *
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select entidad_id,entidad_razon_social,entidad_ruc,entidad_direccion,' .
                'entidad_telefonos,entidad_fax,entidad_correo,activo,xmin as "versionId" from  tb_entidad LIMIT 1';
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
        return 'select entidad_id,entidad_razon_social,entidad_ruc,entidad_direccion,' .
                'entidad_telefonos,entidad_fax,entidad_correo,activo,xmin as "versionId" from tb_entidad where "entidad_id" = ' .
                ($code === NULL ? 'null' : $code);
    }

    /**
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  EntidadModel  */
        $sql = 'update tb_entidad set entidad_razon_social=\'' . $record->get_entidad_razon_social() . '\'' .
                ',entidad_ruc=\'' . $record->get_entidad_ruc() . '\'' .
                ',entidad_direccion=\'' . $record->get_entidad_direccion() . '\'' .
                ',entidad_telefonos=\'' . $record->get_entidad_telefonos() . '\'' .
                ',entidad_fax=\'' . $record->get_entidad_fax() . '\'' .
                ',entidad_correo=\'' . $record->get_entidad_correo() . '\'' .
                ',"activo"=\'' . $record->getActivo() . '\'' .
                ',"usuario_mod"=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "entidad_id" = \'' . $record->getId() . '\'  and xmin =' . $record->getVersionId();
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
        return 'SELECT currval(\'tb_entidad_entidad_id_seq\')';
    }

}

?>