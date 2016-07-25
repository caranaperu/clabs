<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las tipos de costos.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: RegionesModel.php 268 2014-06-27 18:11:45Z aranape $
 * @history ''
 *
 * $Date: 2014-06-27 13:11:45 -0500 (vie, 27 jun 2014) $
 * $Rev: 268 $
 */
class TipoCostosModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $tcostos_codigo;
    protected $tcostos_descripcion;

    /**
     * Setea el codigo unico del tipo de insumo.
     *
     * @param string $tcostos_codigo codigo  unico del tipo de insumo
     */
    public function set_tcostos_codigo($tcostos_codigo) {
        $this->tcostos_codigo = $tcostos_codigo;
        $this->setId($tcostos_codigo);
    }

    /**
     * @return string retorna el codigo unico del tipo de insumo.
     */
    public function get_tcostos_codigo() {
        return $this->tcostos_codigo;
    }

    /**
     * Setea el nombre del tipo de insumo.
     *
     * @param string $tcostos_descripcion nombre del tipo de insumo.
     */
    public function set_tcostos_descripcion($tcostos_descripcion) {
        $this->tcostos_descripcion = $tcostos_descripcion;
    }

    /**
     *
     * @return string con el nombre del tipo de insumo.
     */
    public function get_tcostos_descripcion() {
        return $this->tcostos_descripcion;
    }


    public function &getPKAsArray() {
        $pk['tcostos_codigo'] = $this->getId();
        return $pk;
    }

}

?>