<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo de entidad fisica que representa los datos de los tipos
 * de cambio por rango de fechas . 
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class TipoCambioModel extends \app\common\model\TSLAppCommonBaseModel
{

    protected $tipo_cambio_id;
    protected $moneda_codigo_origen;
    protected $moneda_codigo_destino;
    protected $tipo_cambio_fecha_desde;
    protected $tipo_cambio_fecha_hasta;
    protected $tipo_cambio_tasa_compra;
    protected $tipo_cambio_tasa_venta;


    public function set_tipo_cambio_id($tipo_cambio_id)
    {
        $this->tipo_cambio_id = $tipo_cambio_id;
        $this->setId($tipo_cambio_id);
    }

    public function get_tipo_cambio_id()
    {
        return $this->tipo_cambio_id;
    }

    /**
     * Setea el codigo de la moneda origen del TC.
     *
     * @param $moneda_codigo_origen codigo de la moneda origen del TC.
     */
    public function set_moneda_codigo_origen($moneda_codigo_origen)
    {
        $this->moneda_codigo_origen = $moneda_codigo_origen;
    }


    /**
     * Retorna el codigo de la moneda origen del TC
     *
     * @return string codigo de la unidad de la moneda origen del TC.
     */
    public function get_moneda_codigo_origen()
    {
        return $this->moneda_codigo_origen;
    }

    /**
     * Setea el codigo de la moneda destino del TC
     *
     * @param $moneda_codigo_origen codigo de la moneda destino del TC.
     */
    public function set_moneda_codigo_destino($moneda_codigo_destino)
    {
        $this->moneda_codigo_destino = $moneda_codigo_destino;
    }


    /**
     * Retorna el codigo de la moneda destino del TC.
     *
     * @return string codigo de la moneda destino del TC.
     */
    public function get_moneda_codigo_destino()
    {
        return $this->moneda_codigo_destino;
    }

    /**
     * Setea desde que fecha es valida el TC.
     *
     * @param mixed $tipo_cambio_fecha_desde desde que fecha es valida la TC
     */
    public function set_tipo_cambio_fecha_desde($tipo_cambio_fecha_desde)
    {
        $this->tipo_cambio_fecha_desde = $tipo_cambio_fecha_desde;
    }

    /**
     * Retorna desde que fecha es valida la TC.
     *
     * @return date desde que fecha es valida la TC.
     */
    public function get_tipo_cambio_fecha_desde()
    {
        return $this->tipo_cambio_fecha_desde;
    }

    /**
     * Setea hasta que fecha es valida el TC.
     *
     * @param date $tipo_cambio_fecha_hasta  hasta que fecha es valida el TC.
     */
    public function set_tipo_cambio_fecha_hasta($tipo_cambio_fecha_hasta)
    {
        $this->tipo_cambio_fecha_hasta = $tipo_cambio_fecha_hasta;
    }

    /**
     * Retorn hasta que fecha es valida el TC.
     *
     * @return date hasta que fecha es valida el TC.
     */
    public function get_tipo_cambio_fecha_hasta()
    {
        return $this->tipo_cambio_fecha_hasta;
    }

    /**
     * Setea la tasa de conversion entre la moneda origen y  destino a
     * su tasa de compra
     *
     * @param $tipo_cambio_tasa_compra tasa de compra.
     */
    public function set_tipo_cambio_tasa_compra($tipo_cambio_tasa_compra)
    {
        $this->tipo_cambio_tasa_compra = $tipo_cambio_tasa_compra;
    }


    /**
     * Retorna la tasa de conversion entre la moneda origen y  destino
     * a su tasa de compra.
     *
     * @return double con la tasa de compra.
     */
    public function get_tipo_cambio_tasa_compra()
    {
        return $this->tipo_cambio_tasa_compra;
    }

    /**
     * Setea la tasa de conversion entre la moneda origen y  destino a
     * su tasa de venta
     *
     * @param $tipo_cambio_tasa_compra tasa de compra.
     */
    public function set_tipo_cambio_tasa_venta($tipo_cambio_tasa_venta)
    {
        $this->tipo_cambio_tasa_venta = $tipo_cambio_tasa_venta;
    }


    /**
     * Retorna la tasa de conversion entre la moneda origen y  destino
     * a su tasa de venta.
     *
     * @return double con la tasa de venta.
     */
    public function get_tipo_cambio_tasa_venta()
    {
        return $this->tipo_cambio_tasa_venta;
    }

    public function &getPKAsArray()
    {
        $pk['$tipo_cambio_id'] = $this->getId();
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