<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para definir las ligas atleticas de la liga
 * usuario.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: LigasModel.php 44 2014-02-18 16:33:05Z aranape $
 * @history ''
 *
 * $Date: 2014-02-18 11:33:05 -0500 (mar, 18 feb 2014) $
 * $Rev: 44 $
 */
class LigasModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $ligas_codigo;
    protected $ligas_descripcion;
    protected $ligas_persona_contacto;
    protected $ligas_telefono_oficina;
    protected $ligas_telefono_celular;
    protected $ligas_email;
    protected $ligas_direccion;
    protected $ligas_web_url;

    /**
     * Setea el codigo unico de la liga.
     *
     * @param string $ligas_codigo codigo  unico de la liga
     */
    public function set_ligas_codigo($ligas_codigo) {
        $this->ligas_codigo = $ligas_codigo;
        $this->setId($ligas_codigo);
    }

    /**
     * @return string retorna el codigo unico de la liga.
     */
    public function get_ligas_codigo() {
        return $this->ligas_codigo;
    }

    /**
     * Setea el nombre de la liga.
     *
     * @param string $ligas_descripcion nombre de la liga
     */
    public function set_ligas_descripcion($ligas_descripcion) {
        $this->ligas_descripcion = $ligas_descripcion;
    }

    /**
     *
     * @return string con el nombre de la liga
     */
    public function get_ligas_descripcion() {
        return $this->ligas_descripcion;
    }

    /**
     * Setea la persona de contacto de la liga
     *
     * @param string $ligas_persona_contacto
     */
    public function set_ligas_persona_contacto($ligas_persona_contacto) {
        $this->ligas_persona_contacto = $ligas_persona_contacto;
    }

    /**
     *
     * @return string con la persona de contacto de la liga.
     */
    public function get_ligas_persona_contacto() {
        return $this->ligas_persona_contacto;
    }


    public function set_ligas_telefono_oficina($ligas_telefono_oficina) {
        $this->ligas_telefono_oficina = $ligas_telefono_oficina;
    }

    public function get_ligas_telefono_oficina() {
        return $this->ligas_telefono_oficina;
    }

    public function get_ligas_telefono_celular() {
        return $this->ligas_telefono_celular;
    }

    public function set_ligas_telefono_celular($ligas_telefono_celular) {
        $this->ligas_telefono_celular = $ligas_telefono_celular;
    }

    public function get_ligas_email() {
        return $this->ligas_email;
    }

    public function set_ligas_email($ligas_email) {
        $this->ligas_email = $ligas_email;
    }

    public function get_ligas_direccion() {
        return $this->ligas_direccion;
    }

    public function set_ligas_direccion($ligas_direccion) {
        $this->ligas_direccion = $ligas_direccion;
    }

    public function get_ligas_web_url() {
        return $this->ligas_web_url;
    }

    public function set_ligas_web_url($ligas_web_url) {
        $this->ligas_web_url = $ligas_web_url;
    }

    public function &getPKAsArray() {
        $pk['ligas_codigo'] = $this->getId();
        return $pk;
    }

}

?>