<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para definir los clubes que se asociaran a las ligas
 * usuario.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: ClubesModel.php 43 2014-02-18 16:32:15Z aranape $
 * @history ''
 *
 * $Date: 2014-02-18 11:32:15 -0500 (mar, 18 feb 2014) $
 * $Rev: 43 $
 */
class ClubesModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $clubes_codigo;
    protected $clubes_descripcion;
    protected $clubes_persona_contacto;
    protected $clubes_telefono_oficina;
    protected $clubes_telefono_celular;
    protected $clubes_email;
    protected $clubes_direccion;
    protected $clubes_web_url;

    /**
     * Setea el codigo unico del club.
     *
     * @param string $clubes_codigo codigo  unico del club
     */
    public function set_clubes_codigo($clubes_codigo) {
        $this->clubes_codigo = $clubes_codigo;
        $this->setId($clubes_codigo);
    }

    /**
     * @return string retorna el codigo unico del club.
     */
    public function get_clubes_codigo() {
        return $this->clubes_codigo;
    }

    /**
     * Setea el nombre del club.
     *
     * @param string $clubes_descripcion nombre del club
     */
    public function set_clubes_descripcion($clubes_descripcion) {
        $this->clubes_descripcion = $clubes_descripcion;
    }

    /**
     *
     * @return string con el nombre del club
     */
    public function get_clubes_descripcion() {
        return $this->clubes_descripcion;
    }

   /**
     * Setea la persona de contacto del club
     *
     * @param string $clubes_persona_contacto
     */
    public function set_clubes_persona_contacto($clubes_persona_contacto) {
        $this->clubes_persona_contacto = $clubes_persona_contacto;
    }

    /**
     *
     * @return string con la persona de contacto del club.
     */
    public function get_clubes_persona_contacto() {
        return $this->clubes_persona_contacto;
    }


    public function set_clubes_telefono_oficina($clubes_telefono_oficina) {
        $this->clubes_telefono_oficina = $clubes_telefono_oficina;
    }

    public function get_clubes_telefono_oficina() {
        return $this->clubes_telefono_oficina;
    }

    public function get_clubes_telefono_celular() {
        return $this->clubes_telefono_celular;
    }

    public function set_clubes_telefono_celular($clubes_telefono_celular) {
        $this->clubes_telefono_celular = $clubes_telefono_celular;
    }

    public function get_clubes_email() {
        return $this->clubes_email;
    }

    public function set_clubes_email($clubes_email) {
        $this->clubes_email = $clubes_email;
    }

    public function get_clubes_direccion() {
        return $this->clubes_direccion;
    }

    public function set_clubes_direccion($clubes_direccion) {
        $this->clubes_direccion = $clubes_direccion;
    }

    public function get_clubes_web_url() {
        return $this->clubes_web_url;
    }

    public function set_clubes_web_url($clubes_web_url) {
        $this->clubes_web_url = $clubes_web_url;
    }

    public function &getPKAsArray() {
        $pk['clubes_codigo'] = $this->getId();
        return $pk;
    }

}

?>