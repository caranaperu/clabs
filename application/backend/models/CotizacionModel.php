<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo fisico de la cabecera de cotizacion.
 *
 * @author $Author: aranape $
 * @version $Id: CotizacionModel.php 7 2014-02-11 23:55:54Z aranape $
 * @history , ''
 *
 * $Rev: 7 $
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 */
class CotizacionModel extends \app\common\model\TSLAppCommonBaseModel
{

    protected $cotizacion_id;
    protected $empresa_id;
    protected $cliente_id;
    protected $cotizacion_es_cliente_real;
    protected $cotizacion_numero;
    protected $moneda_codigo;
    protected $cotizacion_fecha;
    protected $cotizacion_cerrada;


    public function set_cotizacion_id($cotizacion_id)
    {
        $this->cotizacion_id = $cotizacion_id;
        $this->setId($cotizacion_id);
    }

    public function get_cotizacion_id()
    {
        return $this->cotizacion_id;
    }

    /**
     * Setea la empresa a la cual pertenece al cotizacion.
     *
     * @param integer $empresa_id id de la empresa a la cual pertenece al cotizacion
     */
    public function set_empresa_id($empresa_id)
    {
        $this->empresa_id = $empresa_id;
    }


    /**
     * Retorna el id de la empresa a la cual pertenece al cotizacion.
     *
     * @return integer con el el id de la empresa a la cual pertenece al cotizacion
     */
    public function get_empresa_id()
    {
        return $this->empresa_id;
    }

    /**
     * Setea la empresa a la que se cotiza.. Este id puede representar
     * un id de una empresa del grupo o a un cliente real.
     * Para discernir se usa el campo "cotizacion_es_cliente_real"
     *
     * @param integer $cliente_id el id de la empresa a la que se cotiza.
     */
    public function set_cliente_id($cliente_id)
    {
        $this->cliente_id = $cliente_id;
    }


    /**
     * Retorna el id del cliente al que se cotiza.
     * Para discernir si es un id de una empresa del grupo o
     * un cliente real , se debe ver el valor del campo "cotizacion_es_cliente_real"
     *
     * @return integer con el id de la empresa a la que se cotiza.
     */
    public function get_cliente_id()
    {
        return $this->cliente_id;
    }

    /**
     * Retorna si la empresa es cliente.
     *
     * @return boolean TRUE si la empresa es cliente
     */
    public function get_cotizacion_es_cliente_real() {
        return $this->cotizacion_es_cliente_real;
    }

    /**
     * Setea si el cliente es un cliente real o es una empresa
     * del grupo.
     * Se aclara que en el id del cliente puede ser a una empresa del grupo
     * que funge como cliente o un verdadero cliente de la empresa que cotiza.
     *
     * @param boolean $cotizacion_es_cliente_real TRUE si lo es.
     */
    public function set_cotizacion_es_cliente_real($cotizacion_es_cliente_real) {
        $this->cotizacion_es_cliente_real = $cotizacion_es_cliente_real;
    }

    /**
     * Setea la moneda de la cotizacion.
     *
     * @param string $moneda_codigo codigo de la moneda de la cotizacion.
     */
    public function set_moneda_codigo($moneda_codigo)
    {
        $this->moneda_codigo = $moneda_codigo;
    }

    /**
     * Retorna el numero de cotizacion.
     *
     * @return integer con el numero de cotizacion.
     */
    public function get_cotizacion_numero() {
        return $this->cotizacion_numero;
    }

    /**
     * Setea el numero de cotizacion, este es unico para cada empresa
     * origen.
     *
     * @param integer $cotizacion_numero numero de cotizacion
     */
    public function set_cotizacion_numero($cotizacion_numero) {
        $this->cotizacion_numero = $cotizacion_numero;
    }
    
    /**
     * Retorna el codigo de la moneda de la cotizacion.
     *
     * @return string codigo de la la moneda de la cotizacion.
     */
    public function get_moneda_codigo()
    {
        return $this->moneda_codigo;
    }

    /**
     * Setea la fecha de la cotizacion.
     *
     * @param date $cotizacion_fecha la fecha de la cotizacion..
     */
    public function set_cotizacion_fecha($cotizacion_fecha)
    {
        $this->cotizacion_fecha = $cotizacion_fecha;
    }


    /**
     * Retorna la fecha de la cotizacion..
     *
     * @return date la fecha de la cotizacion..
     */
    public function get_cotizacion_fecha()
    {
        return $this->cotizacion_fecha;
    }

    /**
     * Setea si una cotizacion sera cerrada y ya no podra
     * modificarse.
     *
     * @param boolean $cotizacion_cerrada true/false
     */
    public function set_cotizacion_cerrada($cotizacion_cerrada) {
        $this->cotizacion_cerrada = $cotizacion_cerrada;
    }

    /**
     * Retorna si una cotizacion esta cerrada , de ser asi
     * ya no pueden alterarse los datos.
     *
     * @return boolean true si esta cerrada.
     */
    public function get_cotizacion_cerrada() {
        return $this->cotizacion_cerrada;
    }

    public function &getPKAsArray()
    {
        $pk['cotizacion_id'] = $this->getId();
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