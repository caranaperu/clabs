<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las Tipos de Prueba,
 * digase pista,campo, marcha en ruta,etc
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: PruebasTipoModel.php 75 2014-03-09 10:25:12Z aranape $
 * @history ''
 *
 * $Date: 2014-03-09 05:25:12 -0500 (dom, 09 mar 2014) $
 * $Rev: 75 $
 */
class PruebasTipoModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $pruebas_tipo_codigo;
    protected $pruebas_tipo_descripcion;

    /**
     * Setea el codigo del tipo de prueba
     *
     * @param string $pruebas_tipo_codigo codigo unico del tipo de prueba
     */
    public function set_pruebas_tipo_codigo($pruebas_tipo_codigo) {
        $this->pruebas_tipo_codigo = $pruebas_tipo_codigo;
        $this->setId($pruebas_tipo_codigo);
    }

    /**
     * @return string retorna el codigo unico del tipo de prueba
     */
    public function get_pruebas_tipo_codigo() {
        return $this->pruebas_tipo_codigo;
    }

    /**
     * Setea la descrpcion del tipo de prueba
     *
     * @param string $paises_descripcion la descrpcion del tipo de prueba
     */
    public function set_pruebas_tipo_descripcion($pruebas_tipo_descripcion) {
        $this->pruebas_tipo_descripcion = $pruebas_tipo_descripcion;
    }

    /**
     *
     * @return string la descripcion del tipo de prueba
     */
    public function get_pruebas_tipo_descripcion() {
        return $this->pruebas_tipo_descripcion;
    }



    public function &getPKAsArray() {
        $pk['pruebas_tipo_codigo'] = $this->getId();
        return $pk;
    }

}

?>