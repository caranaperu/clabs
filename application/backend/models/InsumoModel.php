<?php

if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo  para definir las tipos de insumos a utilizar en una composicion
 * o mezcla.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package CLABS
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class InsumoModel extends \app\common\model\TSLAppCommonBaseModel {
    protected $insumo_id;
    protected $insumo_tipo;
    protected $insumo_codigo;
    protected $insumo_descripcion;
    protected $tinsumo_codigo;
    protected $tcostos_codigo;
    protected $unidad_medida_codigo_ingreso;
    protected $unidad_medida_codigo_costo;
    protected $insumo_merma;
    protected $insumo_costo;
    protected $moneda_codigo_costo;

    private static $_INSUMO_TIPO = ['IN', 'PR'];

    public function set_insumo_id($insumo_id) {
        $this->insumo_id = $insumo_id;
        $this->setId($insumo_id);
    }

    public function get_insumo_id() {
        return $this->insumo_id;
    }

    /**
     * Retorna con el tipo de insumo.
     *
     * @return string con el tipo de insumo.
     */
    public function get_insumo_tipo() {
        return $this->insumo_tipo;
    }

    /**
     * Setea el tipo de insumo , IN para insumo , PR para
     * producto.
     *
     * @param string $insumo_tipo con el tipo de insumo.
     * los valores pueden ser 'IN','PR'
     */
    public function set_insumo_tipo($insumo_tipo) {
        $insumo_tipo_u = strtoupper($insumo_tipo);

        if (in_array($insumo_tipo_u, InsumoModel::$_INSUMO_TIPO)) {
            $this->insumo_tipo = $insumo_tipo_u;
        } else {
            $this->insumo_tipo = '??';
        }
    }


    /**
     * Setea el codigo unico dek insumo.
     *
     * @param string $insumo_codigo codigo  unico del del insumo
     */
    public function set_insumo_codigo($insumo_codigo) {
        $this->insumo_codigo = $insumo_codigo;
    }

    /**
     * @return string retorna el codigo unico del insumo.
     */
    public function get_insumo_codigo() {
        return $this->insumo_codigo;
    }

    /**
     * Setea el nombre del insumo.
     *
     * @param string $insumo_descripcion nombre del insumo.
     */
    public function set_insumo_descripcion($insumo_descripcion) {
        $this->insumo_descripcion = $insumo_descripcion;
    }

    /**
     *
     * @return string con el nombre del insumo.
     */
    public function get_insumo_descripcion() {
        return $this->insumo_descripcion;
    }

    /**
     * Setea el codigo unico del tipo de  insumo.
     *
     * @param string $insumo_codigo codigo  unico del del insumo
     */
    public function set_tinsumo_codigo($tinsumo_codigo) {
        $this->tinsumo_codigo = $tinsumo_codigo;
    }

    /**
     * @return string retorna el codigo unico del tipo de insumo.
     */
    public function get_tinsumo_codigo() {
        return $this->tinsumo_codigo;
    }

    /**
     * Setea el codigo unico del tipo de  costos.
     *
     * @param string $insumo_codigo codigo  unico del tipo de costo.
     */
    public function set_tcostos_codigo($tcostos_codigo) {
        $this->tcostos_codigo = $tcostos_codigo;
    }

    /**
     * @return string retorna el codigo unico del tipo de costos.
     */
    public function get_tcostos_codigo() {
        return $this->tcostos_codigo;
    }


    /**
     * Setea el codigo de la unidad de medida del insumo en las unidades de ingreso
     * al stock.
     *
     * @param string $unidad_medida_codigo_ingreso codigo de la unidad de medida del insumo
     */
    public function set_unidad_medida_codigo_ingreso($unidad_medida_codigo_ingreso) {
        $this->unidad_medida_codigo_ingreso = $unidad_medida_codigo_ingreso;
    }

    /**
     * Retorna el codigo de la unidad de medida del insumo en las unidades de ingreso
     * al stock.
     *
     * @return string el codigo de la unidad de medida del insumo.
     */
    public function get_unidad_medida_codigo_ingreso() {
        return $this->unidad_medida_codigo_ingreso;
    }

    /**
     * Setea el codigo de la unidad de medida del insumo en las unidades minimas
     * de costeo.
     *
     * @param string $unidad_medida_codigo_costo codigo de la unidad de medida del insumo para costos
     */
    public function set_unidad_medida_codigo_costo($unidad_medida_codigo_costo) {
        $this->unidad_medida_codigo_costo = $unidad_medida_codigo_costo;
    }

    /**
     * Retorna el codigo de la unidad de medida del insumoen las unidades minimas
     * de costeo.
     *
     * @return string el codigo de la unidad de medida del insumo para costo
     */
    public function get_unidad_medida_codigo_costo() {
        return $this->unidad_medida_codigo_costo;
    }

    /**
     * Setea el costo de produccion a unidades de costo.
     *
     * @param double $insumo_costo con el costo de produccion.
     */
    public function set_insumo_costo($insumo_costo) {
        $this->insumo_costo = $insumo_costo;
    }


    /**
     * Retorna el costo de produccion a unidades de costo.
     *
     * @return double con el costo de produccion
     */
    public function get_insumo_costo() {
        return $this->insumo_costo;
    }

    /**
     * Setea la cantidad de merma de produccion de este insumo.
     *
     * @param float $insumo_merma merma del insumo.
     */
    public function set_insumo_merma($insumo_merma) {
        $this->insumo_merma = $insumo_merma;
    }


    /**
     * Retorna la cantidad de merma de produccion de este insumo.
     *
     * @return float merma del insumo.
     */
    public function get_insumo_merma() {
        return $this->insumo_merma;
    }

    /**
     * Setea el codigo de la moneda el codigo de la moneda en el que se encuentra
     * el costo.
     *
     * @param $moneda_codigo_costo codigo de la moneda .
     */
    public function set_moneda_codigo_costo($moneda_codigo_costo) {
        $this->moneda_codigo_costo = $moneda_codigo_costo;
    }


    /**
     * Retorna el codigo de la moneda en el que se encuentra
     * el costo.
     *
     * @return string codigo de la moneda.
     */
    public function get_moneda_codigo_costo() {
        return $this->moneda_codigo_costo;
    }

    public function &getPKAsArray() {
        $pk['insumo_id'] = $this->getId();

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