<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo de entidad fisica que representa los datos basicos de la entidad
 * usuaria del sistema como nombre , direccion , telefonos, etc.
 *
 * @author $Author: aranape $
 * @version $Id: EntidadModel.php 7 2014-02-11 23:55:54Z aranape $
 * @history , ''
 *
 * $Rev: 7 $
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 */
class EntidadModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $entidad_id;
    protected $entidad_razon_social;
    protected $entidad_ruc;
    protected $entidad_direccion;
    protected $entidad_correo;
    protected $entidad_telefonos;
    protected $entidad_fax;

    public function get_entidad_id() {
        return $this->entidad_id;
    }

    public function get_entidad_razon_social() {
        return $this->entidad_razon_social;
    }

    public function get_entidad_ruc() {
        return $this->entidad_ruc;
    }


    public function get_entidad_direccion() {
        return $this->entidad_direccion;
    }


    public function get_entidad_correo() {
        return $this->entidad_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @return string con los telefonos
     */
    public function get_entidad_telefonos() {
        return $this->entidad_telefonos;
    }

    public function get_entidad_fax() {
        return $this->entidad_fax;
    }


    public function set_entidad_id($entidad_id) {
        $this->entidad_id = $entidad_id;
        $this->setId($entidad_id);
    }

    public function set_entidad_razon_social($entidad_razon_social) {
        $this->entidad_razon_social = $entidad_razon_social;
    }

    public function set_entidad_ruc($entidad_ruc) {
        $this->entidad_ruc = $entidad_ruc;
    }



    public function set_entidad_direccion($entidad_direccion) {
        $this->entidad_direccion = $entidad_direccion;
    }


    public function set_entidad_correo($entidad_correo) {
        $this->entidad_correo = $entidad_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @param string $entidad_telefonos con los telefonos
     */
    public function set_entidad_telefonos($entidad_telefonos) {
        $this->entidad_telefonos = $entidad_telefonos;
    }

    public function set_entidad_fax($entidad_fax) {
        $this->entidad_fax = $entidad_fax;
    }


    public function &getPKAsArray() {
        $pk['$entidad_id'] = $this->getId();
        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return boolean true
     */
    public function isPKSequenceOrIdentity() {
        return true;
    }

}

?>