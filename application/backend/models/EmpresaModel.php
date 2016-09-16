<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo de entidad fisica que representa los datos basicos de las empresas
 * sean asociadas (fabrica,distribuidora) o clientes.
 *
 * @author $Author: aranape $
 * @version $Id: EmpresaModel.php 7 2014-02-11 23:55:54Z aranape $
 * @history , ''
 *
 * $Rev: 7 $
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 */
class EmpresaModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $empresa_id;
    protected $empresa_razon_social;
    protected $empresa_ruc;
    protected $empresa_direccion;
    protected $empresa_correo;
    protected $empresa_telefonos;
    protected $empresa_fax;
    protected $tipo_empresa_codigo;

    public function get_empresa_id() {
        return $this->empresa_id;
    }

    public function get_empresa_razon_social() {
        return $this->empresa_razon_social;
    }

    public function get_empresa_ruc() {
        return $this->empresa_ruc;
    }


    public function get_empresa_direccion() {
        return $this->empresa_direccion;
    }


    public function get_empresa_correo() {
        return $this->empresa_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @return string con los telefonos
     */
    public function get_empresa_telefonos() {
        return $this->empresa_telefonos;
    }

    public function get_empresa_fax() {
        return $this->empresa_fax;
    }


    public function set_empresa_id($empresa_id) {
        $this->empresa_id = $empresa_id;
        $this->setId($empresa_id);
    }

    public function set_empresa_razon_social($empresa_razon_social) {
        $this->empresa_razon_social = $empresa_razon_social;
    }

    public function set_empresa_ruc($empresa_ruc) {
        $this->empresa_ruc = $empresa_ruc;
    }



    public function set_empresa_direccion($empresa_direccion) {
        $this->empresa_direccion = $empresa_direccion;
    }


    public function set_empresa_correo($empresa_correo) {
        $this->empresa_correo = $empresa_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @param string $empresa_telefonos con los telefonos
     */
    public function set_empresa_telefonos($empresa_telefonos) {
        $this->empresa_telefonos = $empresa_telefonos;
    }

    public function set_empresa_fax($empresa_fax) {
        $this->empresa_fax = $empresa_fax;
    }

    /**
     * Setea el tipo de empresa , sea cliente, importador ,etc
     * En realidad es un codigo de tipo de empresa
     *
     * @param string $tipo_empresa_codigo el codigo del tipo de empresa.
     */
    public function set_tipo_empresa_codigo($tipo_empresa_codigo) {
        $this->tipo_empresa_codigo = $tipo_empresa_codigo;
    }

    /**
     * @return string con el codigo del tipo de empresa.
     */
    public function get_tipo_empresa_codigo() {
        return $this->tipo_empresa_codigo;
    }


    public function &getPKAsArray() {
        $pk['$empresa_id'] = $this->getId();
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