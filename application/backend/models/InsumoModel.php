<?php

if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo  para definir las tipos de insumos a utilizar en una composicion
 * o mezcla.
 * Este modelo es compartido con productos ya que estos son un sub conjunto
 * de datos de este modelo.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package CLABS
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class InsumoModel extends ProductoModel {
    protected $tinsumo_codigo;
    protected $tcostos_codigo;
    protected $unidad_medida_codigo_ingreso;
    protected $insumo_costo;


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
    

}

?>