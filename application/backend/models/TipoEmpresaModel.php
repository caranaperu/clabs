<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los tipos de empresas
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: UnidadMedidaModel.php 136 2014-04-07 00:31:52Z aranape $
 * @history ''
 *
 * $Date: 2014-04-06 19:31:52 -0500 (dom, 06 abr 2014) $
 * $Rev: 136 $
 */
class TipoEmpresaModel extends \app\common\model\TSLAppCommonBaseModel
{

    protected $tipo_empresa_codigo;
    protected $tipo_empresa_descripcion;

    /**
     * Setea el codigo de la monedas
     *
     * @param string $tipo_empresa_codigo codigo unico de la monedas
     */
    public function set_tipo_empresa_codigo($tipo_empresa_codigo)
    {
        $this->tipo_empresa_codigo = $tipo_empresa_codigo;
        $this->setId($tipo_empresa_codigo);
    }

    /**
     * @return string retorna el codigo unico de la monedas
     */
    public function get_tipo_empresa_codigo()
    {
        return $this->tipo_empresa_codigo;
    }

    /**
     * Setea la descrpcion de la monedas
     *
     * @param string $tipo_empresa_descripcionla descrpcion de la monedas
     */
    public function set_tipo_empresa_descripcion($tipo_empresa_descripcion)
    {
        $this->tipo_empresa_descripcion = $tipo_empresa_descripcion;
    }

    /**
     *
     * @return string la descripcion de la monedas
     */
    public function get_tipo_empresa_descripcion()
    {
        return $this->tipo_empresa_descripcion;
    }


    public function &getPKAsArray()
    {
        $pk['tipo_empresa_codigo'] = $this->getId();
        return $pk;
    }

}

?>