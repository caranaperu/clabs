<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las categorias de atletismo
 * digase menores,juveniles,mayores.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: CategoriasModel.php 89 2014-03-25 15:16:16Z aranape $
 * @history ''
 *
 * $Date: 2014-03-25 10:16:16 -0500 (mar, 25 mar 2014) $
 * $Rev: 89 $
 */
class CategoriasModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $categorias_codigo;
    protected $categorias_descripcion;
    protected $categorias_edad_inicial;
    protected $categorias_edad_final;
    protected $categorias_valido_desde;
    protected $categorias_validacion;
    protected $categorias_protected;
    private static $_CATEGORIAS_VALIDACION = array('INF','CAD','JUV', 'MAY', 'MEN', 'S23', 'TOD');

    /**
     * Setea el codigo de la cateoria
     *
     * @param string $categorias_codigo codigo unico de la categoria
     */
    public function set_categorias_codigo($categorias_codigo) {
        $this->categorias_codigo = $categorias_codigo;
        $this->setId($categorias_codigo);
    }

    /**
     * @return string retorna el codigo unico de la categoria
     */
    public function get_categorias_codigo() {
        return $this->categorias_codigo;
    }

    /**
     * Setea la descrpcion de la categoria
     *
     * @param string $paises_descripcion la descrpcion de la unidad de medida
     */
    public function set_categorias_descripcion($categorias_descripcion) {
        $this->categorias_descripcion = $categorias_descripcion;
    }

    /**
     *
     * @return string la descripcion de la categoria
     */
    public function get_categorias_descripcion() {
        return $this->categorias_descripcion;
    }

    /**
     * Setea desde que edad comprende la categoria
     *
     * @param int $categorias_edad_inicial la edad
     */
    public function set_categorias_edad_inicial($categorias_edad_inicial) {
        $this->categorias_edad_inicial = $categorias_edad_inicial;
    }

    /**
     *
     * @return int con la edad desde que se inicia la categoria.
     */
    public function get_categorias_edad_inicial() {
        return $this->categorias_edad_inicial;
    }

    /**
     * Setea Hasta que edad comprende la categoria
     *
     * @param int $categorias_edad_inicial la edad
     */
    public function set_categorias_edad_final($categorias_edad_final) {
        $this->categorias_edad_final = $categorias_edad_final;
    }

    /**
     *
     * @return int con la edad hasta que es valida la categoria.
     */
    public function get_categorias_edad_final() {
        return $this->categorias_edad_final;
    }

    /**
     * El string de retorno debe tener el formato de fecha AAAA-MM-DD
     * @return String con la fecha hasta la cual es valida la categoria
     */
    public function get_categorias_valido_desde() {
        return $this->categorias_valido_desde;
    }

    /**
     * Setea la fecha hasta la cual es valida la categoria
     * es enviado como string y debe contener una fecha valida.
     *
     * @param string $categorias_valido_desde
     */
    public function set_categorias_valido_desde($categorias_valido_desde) {
        $this->categorias_valido_desde = $categorias_valido_desde;
    }

    /**
     * Retorna el tipo de validacion de la categoria
     *
     * @return string indicando la validacion indicando el tipo de validacion
     * los valores pueden ser 'JUV','MAY','MEN','TOD'
     */
    public function get_categorias_validacion() {
        return $this->categorias_validacion;
    }

    /**
     * Setea el tipo de validacion de la categoria
     *
     * @param string $categorias_validacion indicando el tipo de validacion
     * los valores pueden ser 'JUV','MAY','MEN','TOD'
     */
    public function set_categorias_validacion($categorias_validacion) {
        $this->categorias_validacion = $categorias_validacion;

        $categorias_validacion_u = strtoupper($categorias_validacion);

        if (in_array($categorias_validacion_u, CategoriasModel::$_CATEGORIAS_VALIDACION)) {
            $this->categorias_validacion = $categorias_validacion_u;
        } else {
            $this->categorias_validacion = 'TOD'; // Todos
        }
    }

    /**
     * Indica si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @return boolean
     */
    public function get_categorias_protected() {
        return $this->categorias_protected;
    }

    /**
     * Setea si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @param boolean $categorias_protected
     */
    public function set_categorias_protected($categorias_protected) {
        $this->categorias_protected = $categorias_protected;
    }

    public function &getPKAsArray() {
        $pk['categorias_codigo'] = $this->getId();
        return $pk;
    }

}

?>