<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las monedas
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: UnidadMedidaModel.php 136 2014-04-07 00:31:52Z aranape $
 * @history ''
 *
 * $Date: 2014-04-06 19:31:52 -0500 (dom, 06 abr 2014) $
 * $Rev: 136 $
 */
class MonedaModel extends \app\common\model\TSLAppCommonBaseModel
{

    protected $moneda_codigo;
    protected $moneda_simbolo;
    protected $moneda_descripcion;
    protected $moneda_tipo;
    protected $moneda_protected;

    /**
     * Setea el codigo de la monedas
     *
     * @param string $moneda_codigo codigo unico de la monedas
     */
    public function set_moneda_codigo($moneda_codigo)
    {
        $this->moneda_codigo = $moneda_codigo;
        $this->setId($moneda_codigo);
    }

    /**
     * @return string retorna el codigo unico de la monedas
     */
    public function get_moneda_codigo()
    {
        return $this->moneda_codigo;
    }

    /**
     * Setea el simbolo que representa a la monedas
     *
     * @param string $moneda_simbolo simbolo de la monedas
     */
    public function set_moneda_simbolo($moneda_simbolo)
    {
        $this->moneda_simbolo = $moneda_simbolo;
    }

    /**
     * @return string retorna el simbolo que representa a la monedas
     */
    public function get_moneda_simbolo()
    {
        return $this->moneda_simbolo;
    }

    /**
     * Setea la descrpcion de la monedas
     *
     * @param string $moneda_descripcionla descrpcion de la monedas
     */
    public function set_moneda_descripcion($moneda_descripcion)
    {
        $this->moneda_descripcion = $moneda_descripcion;
    }

    /**
     *
     * @return string la descripcion de la monedas
     */
    public function get_moneda_descripcion()
    {
        return $this->moneda_descripcion;
    }


    /**
     * Indica si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @return boolean
     */
    public function get_moneda_protected()
    {
        return $this->moneda_protected;
    }

    /**
     * Setea si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @param boolean $categorias_protected
     */
    public function set_moneda_protected($moneda_protected)
    {
        $this->moneda_protected = $moneda_protected;
    }

    public function &getPKAsArray()
    {
        $pk['moneda_codigo'] = $this->getId();
        return $pk;
    }

}

?>