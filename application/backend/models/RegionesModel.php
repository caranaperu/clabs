<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las regiones atleticas  donde se realizan las
 * competencias
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: RegionesModel.php 268 2014-06-27 18:11:45Z aranape $
 * @history ''
 *
 * $Date: 2014-06-27 13:11:45 -0500 (vie, 27 jun 2014) $
 * $Rev: 268 $
 */
class RegionesModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $regiones_codigo;
    protected $regiones_descripcion;

    /**
     * Setea el codigo unico de la region
     *
     * @param string $regiones_codigo codigo  unico del pais
     */
    public function set_regiones_codigo($regiones_codigo) {
        $this->regiones_codigo = $regiones_codigo;
        $this->setId($regiones_codigo);
    }

    /**
     * @return string retorna el codigo unico de la region
     */
    public function get_regiones_codigo() {
        return $this->regiones_codigo;
    }

    /**
     * Setea el nombre de la region
     *
     * @param string $regiones_descripcion nombre de la region
     */
    public function set_regiones_descripcion($regiones_descripcion) {
        $this->regiones_descripcion = $regiones_descripcion;
    }

    /**
     *
     * @return string con el nombre de la region
     */
    public function get_regiones_descripcion() {
        return $this->regiones_descripcion;
    }


    public function &getPKAsArray() {
        $pk['regiones_codigo'] = $this->getId();
        return $pk;
    }

}

?>