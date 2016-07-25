<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las clasificaciones de las pruebas
 * velocidad,lanzamientos,cetc
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: PruebasClasificacionModel.php 73 2014-03-09 10:23:39Z aranape $
 * @history ''
 *
 * $Date: 2014-03-09 05:23:39 -0500 (dom, 09 mar 2014) $
 * $Rev: 73 $
 */
class PruebasClasificacionModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $pruebas_clasificacion_codigo;
    protected $pruebas_clasificacion_descripcion;
    protected $pruebas_tipo_codigo;
    protected $unidad_medida_codigo;

    /**
     * Setea el codigo de la clasificacion de la prueba
     *
     * @param string $pruebas_clasificacion_codigo codigo unico de la clasificacion de la prueba
     */
    public function set_pruebas_clasificacion_codigo($pruebas_clasificacion_codigo) {
        $this->pruebas_clasificacion_codigo = $pruebas_clasificacion_codigo;
        $this->setId($pruebas_clasificacion_codigo);
    }

    /**
     * @return string retorna el codigo unico de la clasificacion de la prueba
     */
    public function get_pruebas_clasificacion_codigo() {
        return $this->pruebas_clasificacion_codigo;
    }

    /**
     * Setea la descrpcion de la clasificacion de la prueba
     *
     * @param string $paises_descripcion la descrpcion de la clasificacion de la prueba
     */
    public function set_pruebas_clasificacion_descripcion($pruebas_clasificacion_descripcion) {
        $this->pruebas_clasificacion_descripcion = $pruebas_clasificacion_descripcion;
    }

    /**
     *
     * @return string la descripcion de la clasificacion de la prueba
     */
    public function get_pruebas_clasificacion_descripcion() {
        return $this->pruebas_clasificacion_descripcion;
    }

    /**
     *
     * @return string con el codigo de tipo de prueba
     */
    public function get_pruebas_tipo_codigo() {
        return $this->pruebas_tipo_codigo;
    }

    /**
     * Setea el codigo del tipo de prueba , digase campo,pista,etc
     *
     * @param string $pruebas_tipo_codigo
     */
    public function set_pruebas_tipo_codigo($pruebas_tipo_codigo) {
        $this->pruebas_tipo_codigo = $pruebas_tipo_codigo;
    }

    /**
     *
     * @return string con el codigo de la unidad de medida.
     */
    public function get_unidad_medida_codigo() {
        return $this->unidad_medida_codigo;
    }

    /**
     *  Setea el codigo de la unidad de medida.
     * 
     * @param string $unidad_medida_codigo
     */
    public function set_unidad_medida_codigo($unidad_medida_codigo) {
        $this->unidad_medida_codigo = $unidad_medida_codigo;
    }

    public function &getPKAsArray() {
        $pk['pruebas_clasificacion_codigo'] = $this->getId();
        return $pk;
    }

}

?>