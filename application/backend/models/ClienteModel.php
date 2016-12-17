<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo de entidad fisica que representa los datos basicos de los clientes
 *
 * @author $Author: aranape $
 * @version $Id: EmpresaModel.php 7 2014-02-11 23:55:54Z aranape $
 * @history , ''
 *
 * $Rev: 7 $
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 */
class ClienteModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $cliente_id;
    protected $empresa_id;
    protected $cliente_razon_social;
    protected $cliente_ruc;
    protected $cliente_direccion;
    protected $cliente_correo;
    protected $cliente_telefonos;
    protected $cliente_fax;
    protected $tipo_cliente_codigo;

    public function get_cliente_id() {
        return $this->cliente_id;
    }

    /**
     * Retorna el id de la a la que empresa pertenece este cliente
     * @return int con el id de la empresa.
     */
    public function get_empresa_id() {
        return $this->empresa_id;
    }

    public function get_cliente_razon_social() {
        return $this->cliente_razon_social;
    }

    public function get_cliente_ruc() {
        return $this->cliente_ruc;
    }


    public function get_cliente_direccion() {
        return $this->cliente_direccion;
    }


    public function get_cliente_correo() {
        return $this->cliente_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @return string con los telefonos
     */
    public function get_cliente_telefonos() {
        return $this->cliente_telefonos;
    }

    public function get_cliente_fax() {
        return $this->cliente_fax;
    }


    public function set_cliente_id($cliente_id) {
        $this->cliente_id = $cliente_id;
        $this->setId($cliente_id);
    }

    /**
     * Setea a que empresa pertenece este cliente.
     *
     * @param $empresa_id  id de la empresa
     */
    public function set_empresa_id($empresa_id) {
        $this->empresa_id = $empresa_id;
    }

    public function set_cliente_razon_social($cliente_razon_social) {
        $this->cliente_razon_social = $cliente_razon_social;
    }

    public function set_cliente_ruc($cliente_ruc) {
        $this->cliente_ruc = $cliente_ruc;
    }



    public function set_cliente_direccion($cliente_direccion) {
        $this->cliente_direccion = $cliente_direccion;
    }


    public function set_cliente_correo($cliente_correo) {
        $this->cliente_correo = $cliente_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @param string $cliente_telefonos con los telefonos
     */
    public function set_cliente_telefonos($cliente_telefonos) {
        $this->cliente_telefonos = $cliente_telefonos;
    }

    public function set_cliente_fax($cliente_fax) {
        $this->cliente_fax = $cliente_fax;
    }

    /**
     * Setea el tipo de cliente , ej, distribuidor,veterinaria ,etc
     * En realidad es un codigo de tipo de cliente
     *
     * @param string $tipo_cliente_codigo el codigo del tipo de empresa.
     */
    public function set_tipo_cliente_codigo($tipo_cliente_codigo) {
        $this->tipo_cliente_codigo = $tipo_cliente_codigo;
    }

    /**
     * @return string con el codigo del tipo de cliente.
     */
    public function get_tipo_cliente_codigo() {
        return $this->tipo_cliente_codigo;
    }


    public function &getPKAsArray() {
        $pk['$cliente_id'] = $this->getId();
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