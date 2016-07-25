<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los entrenadores
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: EntrenadoresModel.php 7 2014-02-11 23:55:54Z aranape $
 * @history ''
 *
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 * $Rev: 7 $
 */
class EntrenadoresModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $entrenadores_codigo;
    protected $entrenadores_ap_paterno;
    protected $entrenadores_ap_materno;
    protected $entrenadores_nombres;
    protected $entrenadores_nombre_completo;
    protected $entrenadores_nivel_codigo;

    /**
     * Setea el codigo unico del entrenador.
     *
     * @param string $entrenadores_codigo codigo  unico del entrenador
     */
    public function set_entrenadores_codigo($entrenadores_codigo) {
        $this->entrenadores_codigo = $entrenadores_codigo;
        $this->setId($entrenadores_codigo);
    }

    public function set_entrenadores_ap_paterno($entrenadores_ap_paterno) {
        $this->entrenadores_ap_paterno = $entrenadores_ap_paterno;
    }

    public function set_entrenadores_ap_materno($entrenadores_ap_materno) {
        $this->entrenadores_ap_materno = $entrenadores_ap_materno;
    }

    public function set_entrenadores_nombres($entrenadores_nombres) {
        $this->entrenadores_nombres = $entrenadores_nombres;
    }

    public function set_entrenadores_nombre_completo($entrenadores_nombre_completo) {
        $this->entrenadores_nombre_completo = $entrenadores_nombre_completo;
    }

    /**
     * Setea el codigo del nivel del entrenador.
     *
     * @param string $entrenadores_nivel_codigo codigo del nivel del entrenador
     */
    public function set_entrenadores_nivel_codigo($entrenadores_nivel_codigo) {
        $this->entrenadores_nivel_codigo = $entrenadores_nivel_codigo;
    }

    /**
     * @return string $entrenadores_codigo codigo  unico del entrenador
     */
    public function get_entrenadores_codigo() {
        return $this->entrenadores_codigo;
    }

    public function get_entrenadores_ap_paterno() {
        return $this->entrenadores_ap_paterno;
    }

    public function get_entrenadores_ap_materno() {
        return $this->entrenadores_ap_materno;
    }

    public function get_entrenadores_nombres() {
        return $this->entrenadores_nombres;
    }

    /**
     * Retorna el nombre completo el cual es el resultado
     * de concatenar los apellidos y el nombre.
     *
     * @return String con el nombre completo concatenado.
     */
    public function get_per_nombre_completo() {
        return $this->entrenadores_nombre_completo;
    }

    /**
     * Retorna el codigo del nivel del entrenador.
     *
     * @return string con codigo del nivel del entrenador
     */
    public function get_entrenadores_nivel_codigo() {
        return $this->entrenadores_nivel_codigo;
    }

    public function &getPKAsArray() {
        $pk['entrenadores_codigo'] = $this->getId();
        return $pk;
    }

}

?>