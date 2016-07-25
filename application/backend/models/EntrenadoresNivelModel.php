<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las diversos niveles de los entrenadores
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: EntrenadoresNivelModel.php 62 2014-03-09 10:12:14Z aranape $
 * @history ''
 *
 * $Date: 2014-03-09 05:12:14 -0500 (dom, 09 mar 2014) $
 * $Rev: 62 $
 */
class EntrenadoresNivelModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $entrenadores_nivel_codigo;
    protected $entrenadores_nivel_descripcion;
    protected $entrenadores_nivel_protected;

    /**
     * Setea el codigo unico del nivel del entrenador.
     *
     * @param string $entrenadores_nivel_codigo codigo  unico del nivel del entrenador
     */
    public function set_entrenadores_nivel_codigo($entrenadores_nivel_codigo) {
        $this->entrenadores_nivel_codigo = $entrenadores_nivel_codigo;
        $this->setId($entrenadores_nivel_codigo);
    }

    /**
     * @return string retorna el codigo unico del nivel del entrenador
     */
    public function get_entrenadores_nivel_codigo() {
        return $this->entrenadores_nivel_codigo;
    }

    /**
     * Setea la descripcion del nivel
     *
     * @param string $entrenadores_nivel_descripcion descripcion del nivel
     */
    public function set_entrenadores_nivel_descripcion($entrenadores_nivel_descripcion) {
        $this->entrenadores_nivel_descripcion = $entrenadores_nivel_descripcion;
    }

    /**
     *
     * @return string con la descripcion del nivel
     */
    public function get_entrenadores_nivel_descripcion() {
        return $this->entrenadores_nivel_descripcion;
    }

    /**
     * Indica si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @return boolean
     */
    public function get_entrenadores_nivel_protected() {
        return $this->entrenadores_nivel_protected;
    }

    /**
     * Setea si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @param boolean $categorias_protected
     */
    public function set_entrenadores_nivel_protected($entrenadores_nivel_protected) {
        $this->entrenadores_nivel_protected = $entrenadores_nivel_protected;
    }

    public function &getPKAsArray() {
        $pk['entrenadores_nivel_codigo'] = $this->getId();
        return $pk;
    }

}

?>