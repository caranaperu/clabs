<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo de entidad fisica que representa los datos de los items que componen un producto,
 * estos pueden ser otro producto o un insumo.
 *
 * @author $Author: aranape $
 * @version $Id: EntidadModel.php 7 2014-02-11 23:55:54Z aranape $
 * @history , ''
 *
 * $Rev: 7 $
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 */
class ProductoDetalleModel extends \app\common\model\TSLAppCommonBaseModel
{

    protected $producto_detalle_id;
    protected $insumo_id_origen;
    protected $insumo_id;
    protected $unidad_medida_codigo;
    protected $producto_detalle_cantidad;
    protected $producto_detalle_merma;


    public function set_producto_detalle_id($producto_detalle_id)
    {
        $this->producto_detalle_id = $producto_detalle_id;
        $this->setId($producto_detalle_id);
    }

    public function get_producto_detalle_id()
    {
        return $this->producto_detalle_id;
    }

    /**
     * Setea el id del insumo (producto) del cual sera comoponente
     * este registro.
     *
     * @param $insumo_id el id del insumo(producto) del cual es componente.
     */
    public function set_insumo_id_origen($insumo_id_origen)
    {
        $this->insumo_id_origen = $insumo_id_origen;
    }

    /**
     * Retorna  el id del insumo (producto) del cual sera comoponente
     * este registro.
     *
     * @return integer con el id del insumo (producto origen).
     */
    public function get_insumo_id_origen()
    {
        return $this->insumo_id_origen;
    }


    /**
     * Setea el id del insumo que es parte del costo del
     * producto principal , este puede ser insumo u otro
     * producto.
     *
     * @param $insumo_id el ide del insumo o producto parte de este.
     */
    public function set_insumo_id($insumo_id)
    {
        $this->insumo_id = $insumo_id;
    }

    /**
     * Retorna  el id del insumo que es parte del costo del
     * producto principal , este puede ser insumo u otro
     * producto.
     *
     * @return integer con el id del insumo.
     */
    public function get_insumo_id()
    {
        return $this->insumo_id;
    }


    /**
     * Setea el codigo de la unidad de medida en la que se costeara este
     * insumo o producto.
     *
     * @param $unidad_medida_codigo codigo de la unidad de medida en que se costeara.
     */
    public function set_unidad_medida_codigo($unidad_medida_codigo)
    {
        $this->unidad_medida_codigo = $unidad_medida_codigo;
    }


    /**
     * Retorna el codigo de la unidad de medida en la que se costeara este
     * insumo o producto.
     *
     * @return string codigo de la unidad de medida en que se costeara.
     */
    public function get_unidad_medida_codigo()
    {
        return $this->unidad_medida_codigo;
    }

    /**
     * Setea la cantidad en las unidades de medida en que se costeara este elemento dentro
     * del producto al que aporta.
     *
     * @param $producto_detalle_cantidad cantidad en las unidades de medida en que se costeara.
     */
    public function set_producto_detalle_cantidad($producto_detalle_cantidad)
    {
        $this->producto_detalle_cantidad = $producto_detalle_cantidad;
    }


    /**
     * Retorna la cantidad en las unidades de medida en que se costeara este elemento dentro
     * del producto al que aporta.
     *
     * @return double con la cantidad.
     */
    public function get_producto_detalle_cantidad()
    {
        return $this->producto_detalle_cantidad;
    }
    

    /**
     * Retorna la merma del producto o insumo al aplicarse al principal.
     *
     * @return float la merma del producto o insumo
     */
    public function get_producto_detalle_merma() {
        return $this->producto_detalle_merma;
    }

    /**
     * Setea la merma del producto o insumo al aplicarse al principal.
     *
     * @param float $producto_detalle_merma la merma del producto o insumo
     */
    public function set_producto_detalle_merma($producto_detalle_merma) {
        $this->producto_detalle_merma = $producto_detalle_merma;
    }


    public function &getPKAsArray()
    {
        $pk['producto_detalle_id'] = $this->getId();
        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return boolean true
     */
    public function isPKSequenceOrIdentity()
    {
        return true;
    }

}

?>