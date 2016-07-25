<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los atletas
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: AtletasModel.php 79 2014-03-25 10:03:35Z aranape $
 * @history ''
 *
 * $Date: 2014-03-25 05:03:35 -0500 (mar, 25 mar 2014) $
 * $Rev: 79 $
 */
class AtletasModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $atletas_codigo;
    protected $atletas_ap_paterno;
    protected $atletas_ap_materno;
    protected $atletas_nombres;
    protected $atletas_nombre_completo;
    protected $atletas_sexo;
    protected $atletas_nro_documento;
    protected $atletas_nro_pasaporte;
    protected $paises_codigo;
    protected $atletas_fecha_nacimiento;
    protected $atletas_telefono_casa;
    protected $atletas_telefono_celular;
    protected $atletas_email;
    protected $atletas_direccion;
    protected $atletas_observaciones;
    protected $atletas_url_foto;
    protected $atletas_talla_ropa_buzo;
    protected $atletas_talla_ropa_poloshort;
    protected $atletas_talla_zapatillas;
    protected $atletas_norma_zapatillas;
    private static $_TALLAS_ROPA = array('XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', '??');
    private static $_NORMA_ZAPATILLAS = array('UK', 'US', 'NM');

    /**
     * Setea el codigo unico del entrenador.
     *
     * @param string $atletas_codigo codigo  unico del entrenador
     */
    public function set_atletas_codigo($atletas_codigo) {
        $this->atletas_codigo = $atletas_codigo;
        $this->setId($atletas_codigo);
    }

    public function set_atletas_ap_paterno($atletas_ap_paterno) {
        $this->atletas_ap_paterno = $atletas_ap_paterno;
    }

    public function set_atletas_ap_materno($atletas_ap_materno) {
        $this->atletas_ap_materno = $atletas_ap_materno;
    }

    public function set_atletas_nombres($atletas_nombres) {
        $this->atletas_nombres = $atletas_nombres;
    }

    public function set_atletas_nombre_completo($atletas_nombre_completo) {
        $this->atletas_nombre_completo = $atletas_nombre_completo;
    }

    /**
     * Setea el sexo del atleta
     *
     * @param char $atletas_sexo sexo del tleta puede ser 'M' o 'F'
     */
    public function set_atletas_sexo($atletas_sexo) {
        if ($atletas_sexo != 'M' && $atletas_sexo != 'm') {
            $this->atletas_sexo = 'F';
        } else {
            $this->atletas_sexo = 'M';
        }
    }

    public function set_atletas_nro_documento($atletas_nro_documento) {
        $this->atletas_nro_documento = $atletas_nro_documento;
    }

    public function set_atletas_nro_pasaporte($atletas_nro_pasaporte) {
        $this->atletas_nro_pasaporte = $atletas_nro_pasaporte;
    }

    /**
     * Setea el pais al que pertenece el atleta.
     *
     * @param string $paises_codigo con el codigo del pais del atleta
     */
    public function set_paises_codigo($paises_codigo) {
        $this->paises_codigo = $paises_codigo;
    }

    public function set_atletas_fecha_nacimiento($atletas_fecha_nacimiento) {
        $this->atletas_fecha_nacimiento = $atletas_fecha_nacimiento;
    }

    public function set_atletas_telefono_casa($atletas_telefono_casa) {
        $this->atletas_telefono_casa = $atletas_telefono_casa;
    }

    public function set_atletas_telefono_celular($atletas_telefono_celular) {
        $this->atletas_telefono_celular = $atletas_telefono_celular;
    }

    public function set_atletas_email($atletas_email) {
        $this->atletas_email = $atletas_email;
    }

    public function set_atletas_direccion($atletas_direccion) {
        $this->atletas_direccion = $atletas_direccion;
    }

    public function set_atletas_observaciones($atletas_observaciones) {
        $this->atletas_observaciones = $atletas_observaciones;
    }

    public function set_atletas_url_foto($atletas_url_foto) {
        $this->atletas_url_foto = $atletas_url_foto;
    }

    /**
     * Setea la talla del buzo del atleta.
     *
     * @param string $atletas_talla_ropa_buzo indicando la talla de la ropa.
     * los valores pueden ser 'XS','S','M','L','XL','XXL','XXXL','??'
     */
    public function set_atletas_talla_ropa_buzo($atletas_talla_ropa_buzo) {
        $atletas_talla_ropa_u = strtoupper($atletas_talla_ropa_buzo);

        if (in_array($atletas_talla_ropa_u, AtletasModel::$_TALLAS_ROPA)) {
            $this->atletas_talla_ropa_buzo = $atletas_talla_ropa_u;
        } else {
            $this->atletas_talla_ropa_buzo = '??';
        }
    }

    /**
     * Setea la talla de la ropa del short/polo del atleta.
     *
     * @param string $atletas_talla_ropa_poloshort indicando la talla de la ropa.
     * los valores pueden ser 'XS','S','M','L','XL','XXL','XXXL','??'
     */
    public function set_atletas_talla_ropa_poloshort($atletas_talla_ropa_poloshort) {
        $atletas_talla_ropa_u = strtoupper($atletas_talla_ropa_poloshort);

        if (in_array($atletas_talla_ropa_u, AtletasModel::$_TALLAS_ROPA)) {
            $this->atletas_talla_ropa_poloshort = $atletas_talla_ropa_u;
        } else {
            $this->atletas_talla_ropa_poloshort = '??';
        }
    }

    /**
     * Setea la talla de zapatillas del atleta.
     *
     * @param double $atletas_talla_zapatillas con la talla de zapatillas
     */
    public function set_atletas_talla_zapatillas($atletas_talla_zapatillas) {
        $this->atletas_talla_zapatillas = $atletas_talla_zapatillas;
    }

           /**
     * Setea la norma en que se especifica la talla de la zapatilla.
     *
     * @param string $atletas_norma_zapatillas indicando la norma de la zapatilla
     * los valores pueden ser 'UK','US','NM','??'
     */
    public function set_atletas_norma_zapatillas($atletas_norma_zapatillas) {
        $atletas_norma_zapatillas_u = strtoupper($atletas_norma_zapatillas);

        if (in_array($atletas_norma_zapatillas_u, AtletasModel::$_NORMA_ZAPATILLAS)) {
            $this->atletas_norma_zapatillas = $atletas_norma_zapatillas_u;
        } else {
            $this->atletas_norma_zapatillas = '??';
        }
    }

    /**
     * @return string $atletas_codigo codigo  unico del entrenador
     */
    public function get_atletas_codigo() {
        return $this->atletas_codigo;
    }

    public function get_atletas_ap_paterno() {
        return $this->atletas_ap_paterno;
    }

    public function get_atletas_ap_materno() {
        return $this->atletas_ap_materno;
    }

    public function get_atletas_nombres() {
        return $this->atletas_nombres;
    }

    /**
     * Retorna el nombre completo el cual es el resultado
     * de concatenar los apellidos y el nombre.
     *
     * @return String con el nombre completo concatenado.
     */
    public function get_per_nombre_completo() {
        return $this->atletas_nombre_completo;
    }

    /**
     *
     * @return char con el  sexo del atleta puede ser 'M' o 'F'
     */
    public function get_atletas_sexo() {
        return $this->atletas_sexo;
    }

    public function get_atletas_nro_documento() {
        return $this->atletas_nro_documento;
    }

    public function get_atletas_nro_pasaporte() {
        return $this->atletas_nro_pasaporte;
    }

    public function get_paises_codigo() {
        return $this->paises_codigo;
    }

    public function get_atletas_fecha_nacimiento() {
        return $this->atletas_fecha_nacimiento;
    }

    public function get_atletas_telefono_casa() {
        return $this->atletas_telefono_casa;
    }

    public function get_atletas_telefono_celular() {
        return $this->atletas_telefono_celular;
    }

    public function get_atletas_email() {
        return $this->atletas_email;
    }

    public function get_atletas_direccion() {
        return $this->atletas_direccion;
    }

    public function get_atletas_observaciones() {
        return $this->atletas_observaciones;
    }

    public function get_atletas_url_foto() {
        return $this->atletas_url_foto;
    }

    /**
     * Retorna la talla del buzo
     *
     * @return string indicando la talla de la ropa.
     * los valores pueden ser 'XS','S','M','L','XL','XXL','XXXL','??'
     */
    public function get_atletas_talla_ropa_buzo() {
        return $this->atletas_talla_ropa_buzo;
    }

    /**
     * Retorna la talla del polo y short del atleta.
     *
     * @return string indicando la talla de la ropa.
     * los valores pueden ser 'XS','S','M','L','XL','XXL','XXXL','??'
     */
    public function get_atletas_talla_ropa_poloshort() {
        return $this->atletas_talla_ropa_poloshort;
    }

    /**
     * Retorna con la talla de zapatillas del atleta.
     *
     * @return double con la talla de zapatillas
     */
    public function get_atletas_talla_zapatillas() {
        return $this->atletas_talla_zapatillas;
    }


    /**
     * Retorna la norma de la zapatilla.
     *
     * @return string indicando la norma de la zapatilla.
     * los valores pueden ser 'UK','US','NM','??'
     */
    public function get_atletas_norma_zapatillas() {
        return $this->atletas_norma_zapatillas;
    }

    public function &getPKAsArray() {
        $pk['atletas_codigo'] = $this->getId();
        return $pk;
    }

}

?>