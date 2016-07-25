<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

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

    protected $insumo_codigo;
    protected $insumo_descripcion;
    protected $tinsumo_codigo;
    protected $tcostos_codigo;
    protected $unidad_medida_codigo;
    protected $insumo_merma;

    /**
     * Setea el codigo unico dek insumo.
     *
     * @param string $insumo_codigo codigo  unico del del insumo
     */
    public function set_insumo_codigo($insumo_codigo) {
        $this->insumo_codigo = $insumo_codigo;
        $this->setId($insumo_codigo);
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
     * Setea el codigo de la unidad de medida del insumo.
     *
     * @param string $unidad_medida_codigo codigo de la unidad de medida del insumo
     */
    public function set_unidad_medida_codigo($unidad_medida_codigo)
    {
        $this->unidad_medida_codigo = $unidad_medida_codigo;
    }

    /**
     * Retorna el codigo de la unidad de medida del insumo.
     *
     * @return string el codigo de la unidad de medida del insumo.
     */
    public function get_unidad_medida_codigo()
    {
        return $this->unidad_medida_codigo;
    }

    /**
     * Setea la cantidad de merma de produccion de este insumo.
     *
     * @param float $insumo_merma merma del insumo.
     */
    public function set_insumo_merma($insumo_merma)
    {
        $this->insumo_merma = $insumo_merma;
    }


    /**
     * Retorna la cantidad de merma de produccion de este insumo.
     *
     * @return float merma del insumo.
     */
    public function get_insumo_merma()
    {
        return $this->insumo_merma;
    }


    public function &getPKAsArray() {
        $pk['insumo_codigo'] = $this->getId();
        return $pk;
    }

}

?>