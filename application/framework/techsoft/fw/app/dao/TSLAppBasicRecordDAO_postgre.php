<?php

namespace app\common\dao;

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico para el postgresql e implementa solo la parte comun
 * y especifica de la  base de datos POSTGRES SQL, como en este caso son la determinacion de
 * algunos errores comunes a la bases de datos de diferente marca , pero que en el
 * caso del POSTGRESQL no usa los estandares ansi. Todas los DAO para postgres
 * deben implementar esta clase , la misma que es abstracta
 *
 * @author $Author: aranape $
 * @since 06-FEB-2013
 * @version $Id: TSLAppBasicRecordDAO_postgre.php 4 2014-02-11 03:31:42Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-02-10 22:31:42 -0500 (lun, 10 feb 2014) $
 * $Rev: 4 $
 */
abstract class TSLAppBasicRecordDAO_postgre extends \TSLBasicRecordDAO {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        $this->activeSearchOnly = $activeSearchOnly;
    }

    /**
     * IMPORTANTE: Este metodo usado aqui es solo para postgreSQL ya que
     * no envian codigo de error solo mensaje.
     *
     * @see \TSLBasicRecordDAO::isDuplicateKeError()
     *
     * @return boolean
     */
    public function isDuplicateKeyError($errorCode, $errorMsg) {
        $pos = stripos($errorMsg, 'duplicate key value violates');
        if ($pos !== FALSE) {
            return TRUE;
        }
        return FALSE;
    }

    /**
     * IMPORTANTE: Este metodo usado aqui es solo para postgreSQL ya que
     * no envian codigo de error solo mensaje.
     *
     * @see \TSLBasicRecordDAO::isForeignKeyError()
     *
     * @return boolean
     */
    public function isForeignKeyError($errorCode, $errorMsg) {
        $pos = stripos($errorMsg, 'violates foreign key');
        if ($pos !== FALSE) {
            return TRUE;
        }
        return FALSE;
    }

    /**
     * IMPORTANTE: Este metodo usado aqui es solo para postgreSQL ya que
     * no envian codigo de error solo mensaje, ademas este error formalmente no existe
     * y sera usado cuando el error de registro modificado sea detectado
     * dentro de un Stored Procedure , queda al implementador realizarlo
     * y enviar el error en caso suceda.
     * Actualmente se espera que el mensaje contenga el texto 'record modified'
     *
     * @see \TSLBasicRecordDAO::isForeignKeyError()
     *
     * @return boolean
     */
    public function isRecordModifiedError($errorCode, $errorMsg) {
        $pos = stripos($errorMsg, 'record modified');
        if ($pos !== FALSE) {
            return TRUE;
        }
        return FALSE;
    }

}

?>