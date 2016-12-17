<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo fisico de cada item de la cotizacion.
 *
 * @author $Author: aranape $
 * @version $Id: CotizacionModel.php 7 2014-02-11 23:55:54Z aranape $
 * @history , ''
 *
 * $Rev: 7 $
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 */
class CotizacionDetalleModel extends \app\common\model\TSLAppCommonBaseModel
{

    protected $cotizacion_detalle_id;
    protected $cotizacion_id;
    protected $insumo_id;
    protected $cotizacion_detalle_cantidad;
    protected $unidad_medida_codigo;
    protected $cotizacion_detalle_precio;
    protected $cotizacion_detalle_total;
    protected $cotizacion_cerrada;
    protected $regla_by_costo;
    protected $regla_porcentaje;
    protected $tipo_cambio_tasa_compra;
    protected $tipo_cambio_tasa_venta;

    public function set_cotizacion_detalle_id($cotizacion_detalle_id)
    {
        $this->cotizacion_detalle_id = $cotizacion_detalle_id;
        $this->setId($cotizacion_detalle_id);
    }

    public function get_cotizacion_detalle_id()
    {
        return $this->cotizacion_detalle_id;
    }


    /**
     * Setea a la cotizacion que corresponde este item.
     *
     * @param integer $cotizacion_id id de la cotizacion a la que corresponde este item.
     */
    public function set_cotizacion_id($cotizacion_id)
    {
        $this->cotizacion_id = $cotizacion_id;
    }

    /**
     * @return integer con el id de la cotizacion a la que corresponde este item.
     */
    public function get_cotizacion_id()
    {
        return $this->cotizacion_id;
    }

    /**
     * Setea el insumo a cotizar, si la empresa es una fabrica o distribuidor
     * este debe ser del tipo producto.
     *
     * @param integer $insumo_id id del insumo a cotizar.
     */
    public function set_insumo_id($insumo_id)
    {
        $this->insumo_id = $insumo_id;
    }


    /**
     * Retorna el id del insumo a cotizar.
     *
     * @return integer con el el id del insumo a cotizar.
     */
    public function get_insumo_id()
    {
        return $this->insumo_id;
    }


    /**
     * Setea el precio total del  insumo a cotizar..
     *
     * @param double $cotizacion_detalle_total precio del insumo.
     */
    public function set_cotizacion_detalle_total($cotizacion_detalle_total)
    {
        $this->cotizacion_detalle_total = $cotizacion_detalle_total;
    }

    /**
     * Retorna el el precio total del insumo a cotizar..
     *
     * @return double con el precio total  del insumo a cotizar..
     */
    public function get_cotizacion_detalle_total()
    {
        return $this->cotizacion_detalle_total;
    }

    /**
     * Retorna la cantidad a cotizar..
     *
     * @return double con la cantidad a cotizar.
     */
    public function get_cotizacion_detalle_cantidad() {
        return $this->cotizacion_detalle_cantidad;
    }

    /**
     * Setea la cantidad a cotizar..
     *
     * @param double $cotizacion_detalle_cantidad la cantidad a cotizar.
     */
    public function set_cotizacion_detalle_cantidad($cotizacion_detalle_cantidad) {
        $this->cotizacion_detalle_cantidad = $cotizacion_detalle_cantidad;
    }

    /**
     * Retorna el codigo de la unidad de medida del producto a cotizar.
     *
     * @return string codigo de la  unidad de medida.
     */
    public function get_unidad_medida_codigo() {
        return $this->unidad_medida_codigo;
    }

    /**
     * Setea la unidad de medida del producto a cotizar.
     *
     * @param string $unidad_medida_codigo codigo de la unidad de medida
     */
    public function set_unidad_medida_codigo($unidad_medida_codigo) {
        $this->unidad_medida_codigo = $unidad_medida_codigo;
    }

    /**
     * Retorna el precio unitario del producto.
     * 
     * @return double con el precio unitario del producto.
     */
    public function get_cotizacion_detalle_precio() {
        return $this->cotizacion_detalle_precio;
    }

    /**
     * Setea el precio unitario del producto.
     * 
     * @param double $cotizacion_detalle_precio el precio unitario del producto.
     */
    public function set_cotizacion_detalle_precio($cotizacion_detalle_precio) {
        $this->cotizacion_detalle_precio = $cotizacion_detalle_precio;
    }

    /**
     * Setea si una cotizacion sera cerrada y ya no podra
     * modificarse.
     *
     * @param boolean $cotizacion_cerrada true/false
     */
    public function setCotizacionCerrada($cotizacion_cerrada) {
        $this->cotizacion_cerrada = $cotizacion_cerrada;
    }

    /**
     * Retorna si una cotizacion esta cerrada , de ser asi
     * ya no pueden alterarse los datos.
     *
     * @return boolean true si esta cerrada.
     */
    public function getCotizacionCerrada() {
        return $this->cotizacion_cerrada;
    }


    /**
     * Setea con que tipo de regla se determino es precio de
     * cotizacion , esto es por motivos historicos.
     *
     * @param boolean $regla_by_costo true/false/null
     */
    public function setReglaByCosto($regla_by_costo) {
        $this->regla_by_costo = $regla_by_costo;
    }


    /**
     *
     * Retorna con que tipo de regla se determino es precio de
     * cotizacion , esto es por motivos historicos.
     *
     * En el caso que se un cliente final este valor sera null.
     *
     * @return boolean true/false/null
     */
    public function getReglaByCosto() {
        return $this->regla_by_costo;
    }

    /**
     * Setea el porcentaje de la regla aplicada al costo,
     * en el caso que se cotize a un cliente final puede ser null.
     *
     * @param double $regla_porcentaje el porcentaje o null.
     */
    public function setReglaPorcentaje($regla_porcentaje) {
        $this->regla_porcentaje = $regla_porcentaje;
    }

    /**
     * Retorna el porcentaje de la regla aplicada al costo,
     * en el caso que se cotize a un cliente final puede ser null.
     *
     * @return double un valor o null
     */
    public function getReglaPorcentaje() {
        return $this->regla_porcentaje;
    }

    /**
     * Setea el tipo de cambio de compra que se aplico
     * para determinar el precio .
     *
     * @param double $tipo_cambio_tasa_compra
     */
    public function setTipoCambioTasaCompra($tipo_cambio_tasa_compra) {
        $this->tipo_cambio_tasa_compra = $tipo_cambio_tasa_compra;
    }


    /**
     * Retorna el tipo de cambio de compra que se aplico
     * para determinar el precio .
     *
     * @return double con el tc de compra.
     */
    public function getTipoCambioTasaCompra() {
        return $this->tipo_cambio_tasa_compra;
    }

    /**
     * Setea el tipo de cambio de ventas que se aplico
     * para determinar el precio .
     *
     * @param double $tipo_cambio_tasa_venta
     */
    public function setTipoCambioTasaVenta($tipo_cambio_tasa_venta) {
        $this->tipo_cambio_tasa_venta = $tipo_cambio_tasa_venta;
    }

    /**
     * Retorna el tipo de cambio de venta que se aplico
     * para determinar el precio .
     *
     * @return double con el tc de venta.
     */
    public function getTipoCambioTasaVenta() {
        return $this->tipo_cambio_tasa_venta;
    }


    public function &getPKAsArray()
    {
        $pk['cotizacion_detalle_id'] = $this->getId();
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