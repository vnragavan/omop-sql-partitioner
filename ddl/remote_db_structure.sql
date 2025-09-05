--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-1.pgdg110+1)
-- Dumped by pg_dump version 14.18 (Homebrew)

-- Started on 2025-06-09 19:15:35 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 24589)
-- Name: omopcdm; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA omopcdm;


ALTER SCHEMA omopcdm OWNER TO postgres;

--
-- TOC entry 4 (class 2615 OID 16386)
-- Name: results; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA results;


ALTER SCHEMA results OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 16552)
-- Name: copyif(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.copyif(tablename text, filename text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
BEGIN
EXECUTE (
    format('DO
    $do$
    BEGIN
    IF NOT EXISTS (SELECT FROM %s) THEN
        COPY %s FROM ''%s'' WITH DELIMITER E''\t'' CSV HEADER QUOTE E''\b'' ;
    END IF;
    END
    $do$
', tablename, tablename, filename));
END
$_$;


ALTER FUNCTION public.copyif(tablename text, filename text) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 24764)
-- Name: copyifcomma(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.copyifcomma(tablename text, filename text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
    BEGIN
    EXECUTE (
      format('DO
      $do$
      BEGIN
      IF NOT EXISTS (SELECT FROM %s) THEN
         COPY %s FROM ''%s'' WITH DELIMITER E'','' CSV HEADER NULL '''' ;
      END IF;
      END
      $do$
    ', tablename, tablename, filename));
    END
    $_$;


ALTER FUNCTION public.copyifcomma(tablename text, filename text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 24663)
-- Name: care_site; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.care_site (
    care_site_id integer NOT NULL,
    care_site_name character varying(255),
    place_of_service_concept_id integer,
    location_id integer,
    care_site_source_value character varying(50),
    place_of_service_source_value character varying(50)
);


ALTER TABLE omopcdm.care_site OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 24702)
-- Name: cdm_source; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.cdm_source (
    cdm_source_name character varying(255) NOT NULL,
    cdm_source_abbreviation character varying(25) NOT NULL,
    cdm_holder character varying(255) NOT NULL,
    source_description text,
    source_documentation_reference character varying(255),
    cdm_etl_reference character varying(255),
    source_release_date date NOT NULL,
    cdm_release_date date NOT NULL,
    cdm_version character varying(10),
    cdm_version_concept_id integer NOT NULL,
    vocabulary_version character varying(20) NOT NULL
);


ALTER TABLE omopcdm.cdm_source OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 24747)
-- Name: cohort; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.cohort (
    cohort_definition_id integer NOT NULL,
    subject_id integer NOT NULL,
    cohort_start_date date NOT NULL,
    cohort_end_date date NOT NULL
);


ALTER TABLE omopcdm.cohort OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 24750)
-- Name: cohort_definition; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.cohort_definition (
    cohort_definition_id integer NOT NULL,
    cohort_definition_name character varying(255) NOT NULL,
    cohort_definition_description text,
    definition_type_concept_id integer NOT NULL,
    cohort_definition_syntax text,
    subject_concept_id integer NOT NULL,
    cohort_initiation_date date
);


ALTER TABLE omopcdm.cohort_definition OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 24708)
-- Name: concept; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.concept (
    concept_id integer NOT NULL,
    concept_name character varying(255) NOT NULL,
    domain_id character varying(20) NOT NULL,
    vocabulary_id character varying(20) NOT NULL,
    concept_class_id character varying(20) NOT NULL,
    standard_concept character varying(1),
    concept_code character varying(50) NOT NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason character varying(1)
);


ALTER TABLE omopcdm.concept OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 24735)
-- Name: concept_ancestor; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.concept_ancestor (
    ancestor_concept_id integer NOT NULL,
    descendant_concept_id integer NOT NULL,
    min_levels_of_separation integer NOT NULL,
    max_levels_of_separation integer NOT NULL
);


ALTER TABLE omopcdm.concept_ancestor OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 24720)
-- Name: concept_class; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.concept_class (
    concept_class_id character varying(20) NOT NULL,
    concept_class_name character varying(255) NOT NULL,
    concept_class_concept_id integer NOT NULL
);


ALTER TABLE omopcdm.concept_class OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 24723)
-- Name: concept_relationship; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.concept_relationship (
    concept_id_1 integer NOT NULL,
    concept_id_2 integer NOT NULL,
    relationship_id character varying(20) NOT NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason character varying(1)
);


ALTER TABLE omopcdm.concept_relationship OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 24729)
-- Name: concept_synonym; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.concept_synonym (
    concept_id integer NOT NULL,
    concept_synonym_name character varying(1000) NOT NULL,
    language_concept_id integer NOT NULL
);


ALTER TABLE omopcdm.concept_synonym OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 24687)
-- Name: condition_era; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.condition_era (
    condition_era_id integer NOT NULL,
    person_id integer NOT NULL,
    condition_concept_id integer NOT NULL,
    condition_era_start_date date NOT NULL,
    condition_era_end_date date NOT NULL,
    condition_occurrence_count integer
);


ALTER TABLE omopcdm.condition_era OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 24603)
-- Name: condition_occurrence; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.condition_occurrence (
    condition_occurrence_id integer NOT NULL,
    person_id integer NOT NULL,
    condition_concept_id integer NOT NULL,
    condition_start_date date NOT NULL,
    condition_start_datetime timestamp without time zone,
    condition_end_date date,
    condition_end_datetime timestamp without time zone,
    condition_type_concept_id integer NOT NULL,
    condition_status_concept_id integer,
    stop_reason character varying(20),
    provider_id integer,
    visit_occurrence_id integer,
    visit_detail_id integer,
    condition_source_value character varying(50),
    condition_source_concept_id integer,
    condition_status_source_value character varying(50)
);


ALTER TABLE omopcdm.condition_occurrence OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 24672)
-- Name: cost; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.cost (
    cost_id integer NOT NULL,
    cost_event_id integer NOT NULL,
    cost_domain_id character varying(20) NOT NULL,
    cost_type_concept_id integer NOT NULL,
    currency_concept_id integer,
    total_charge numeric,
    total_cost numeric,
    total_paid numeric,
    paid_by_payer numeric,
    paid_by_patient numeric,
    paid_patient_copay numeric,
    paid_patient_coinsurance numeric,
    paid_patient_deductible numeric,
    paid_by_primary numeric,
    paid_ingredient_cost numeric,
    paid_dispensing_fee numeric,
    payer_plan_period_id integer,
    amount_allowed numeric,
    revenue_code_concept_id integer,
    revenue_code_source_value character varying(50),
    drg_concept_id integer,
    drg_source_value character varying(3)
);


ALTER TABLE omopcdm.cost OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 24633)
-- Name: death; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.death (
    person_id integer NOT NULL,
    death_date date NOT NULL,
    death_datetime timestamp without time zone,
    death_type_concept_id integer,
    cause_concept_id integer,
    cause_source_value character varying(50),
    cause_source_concept_id integer
);


ALTER TABLE omopcdm.death OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 24615)
-- Name: device_exposure; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.device_exposure (
    device_exposure_id integer NOT NULL,
    person_id integer NOT NULL,
    device_concept_id integer NOT NULL,
    device_exposure_start_date date NOT NULL,
    device_exposure_start_datetime timestamp without time zone,
    device_exposure_end_date date,
    device_exposure_end_datetime timestamp without time zone,
    device_type_concept_id integer NOT NULL,
    unique_device_id character varying(255),
    production_id character varying(255),
    quantity integer,
    provider_id integer,
    visit_occurrence_id integer,
    visit_detail_id integer,
    device_source_value character varying(50),
    device_source_concept_id integer,
    unit_concept_id integer,
    unit_source_value character varying(50),
    unit_source_concept_id integer
);


ALTER TABLE omopcdm.device_exposure OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 24717)
-- Name: domain; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.domain (
    domain_id character varying(20) NOT NULL,
    domain_name character varying(255) NOT NULL,
    domain_concept_id integer NOT NULL
);


ALTER TABLE omopcdm.domain OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 24681)
-- Name: dose_era; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.dose_era (
    dose_era_id integer NOT NULL,
    person_id integer NOT NULL,
    drug_concept_id integer NOT NULL,
    unit_concept_id integer NOT NULL,
    dose_value numeric NOT NULL,
    dose_era_start_date date NOT NULL,
    dose_era_end_date date NOT NULL
);


ALTER TABLE omopcdm.dose_era OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 24678)
-- Name: drug_era; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.drug_era (
    drug_era_id integer NOT NULL,
    person_id integer NOT NULL,
    drug_concept_id integer NOT NULL,
    drug_era_start_date date NOT NULL,
    drug_era_end_date date NOT NULL,
    drug_exposure_count integer,
    gap_days integer
);


ALTER TABLE omopcdm.drug_era OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 24606)
-- Name: drug_exposure; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.drug_exposure (
    drug_exposure_id integer NOT NULL,
    person_id integer NOT NULL,
    drug_concept_id integer NOT NULL,
    drug_exposure_start_date date NOT NULL,
    drug_exposure_start_datetime timestamp without time zone,
    drug_exposure_end_date date NOT NULL,
    drug_exposure_end_datetime timestamp without time zone,
    verbatim_end_date date,
    drug_type_concept_id integer NOT NULL,
    stop_reason character varying(20),
    refills integer,
    quantity numeric,
    days_supply integer,
    sig text,
    route_concept_id integer,
    lot_number character varying(50),
    provider_id integer,
    visit_occurrence_id integer,
    visit_detail_id integer,
    drug_source_value character varying(50),
    drug_source_concept_id integer,
    route_source_value character varying(50),
    dose_unit_source_value character varying(50)
);


ALTER TABLE omopcdm.drug_exposure OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 24741)
-- Name: drug_strength; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.drug_strength (
    drug_concept_id integer NOT NULL,
    ingredient_concept_id integer NOT NULL,
    amount_value numeric,
    amount_unit_concept_id integer,
    numerator_value numeric,
    numerator_unit_concept_id integer,
    denominator_value numeric,
    denominator_unit_concept_id integer,
    box_size integer,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason character varying(1)
);


ALTER TABLE omopcdm.drug_strength OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 24690)
-- Name: episode; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.episode (
    episode_id integer NOT NULL,
    person_id integer NOT NULL,
    episode_concept_id integer NOT NULL,
    episode_start_date date NOT NULL,
    episode_start_datetime timestamp without time zone,
    episode_end_date date,
    episode_end_datetime timestamp without time zone,
    episode_parent_id integer,
    episode_number integer,
    episode_object_concept_id integer NOT NULL,
    episode_type_concept_id integer NOT NULL,
    episode_source_value character varying(50),
    episode_source_concept_id integer
);


ALTER TABLE omopcdm.episode OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 24693)
-- Name: episode_event; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.episode_event (
    episode_id integer NOT NULL,
    event_id integer NOT NULL,
    episode_event_field_concept_id integer NOT NULL
);


ALTER TABLE omopcdm.episode_event OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 24654)
-- Name: fact_relationship; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.fact_relationship (
    domain_concept_id_1 integer NOT NULL,
    fact_id_1 integer NOT NULL,
    domain_concept_id_2 integer NOT NULL,
    fact_id_2 integer NOT NULL,
    relationship_concept_id integer NOT NULL
);


ALTER TABLE omopcdm.fact_relationship OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 24657)
-- Name: location; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.location (
    location_id integer NOT NULL,
    address_1 character varying(50),
    address_2 character varying(50),
    city character varying(50),
    state character varying(2),
    zip character varying(9),
    county character varying(20),
    location_source_value character varying(50),
    country_concept_id integer,
    country_source_value character varying(80),
    latitude numeric,
    longitude numeric
);


ALTER TABLE omopcdm.location OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 24621)
-- Name: measurement; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.measurement (
    measurement_id integer NOT NULL,
    person_id integer NOT NULL,
    measurement_concept_id integer NOT NULL,
    measurement_date date NOT NULL,
    measurement_datetime timestamp without time zone,
    measurement_time character varying(10),
    measurement_type_concept_id integer NOT NULL,
    operator_concept_id integer,
    value_as_number numeric,
    value_as_concept_id integer,
    unit_concept_id integer,
    range_low numeric,
    range_high numeric,
    provider_id integer,
    visit_occurrence_id integer,
    visit_detail_id integer,
    measurement_source_value character varying(50),
    measurement_source_concept_id integer,
    unit_source_value character varying(50),
    unit_source_concept_id integer,
    value_source_value character varying(50),
    measurement_event_id integer,
    meas_event_field_concept_id integer
);


ALTER TABLE omopcdm.measurement OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 24696)
-- Name: metadata; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.metadata (
    metadata_id integer NOT NULL,
    metadata_concept_id integer NOT NULL,
    metadata_type_concept_id integer NOT NULL,
    name character varying(250) NOT NULL,
    value_as_string character varying(250),
    value_as_concept_id integer,
    value_as_number numeric,
    metadata_date date,
    metadata_datetime timestamp without time zone
);


ALTER TABLE omopcdm.metadata OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 24636)
-- Name: note; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.note (
    note_id integer NOT NULL,
    person_id integer NOT NULL,
    note_date date NOT NULL,
    note_datetime timestamp without time zone,
    note_type_concept_id integer NOT NULL,
    note_class_concept_id integer NOT NULL,
    note_title character varying(250),
    note_text text NOT NULL,
    encoding_concept_id integer NOT NULL,
    language_concept_id integer NOT NULL,
    provider_id integer,
    visit_occurrence_id integer,
    visit_detail_id integer,
    note_source_value character varying(50),
    note_event_id integer,
    note_event_field_concept_id integer
);


ALTER TABLE omopcdm.note OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 24642)
-- Name: note_nlp; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.note_nlp (
    note_nlp_id integer NOT NULL,
    note_id integer NOT NULL,
    section_concept_id integer,
    snippet character varying(250),
    "offset" character varying(50),
    lexical_variant character varying(250) NOT NULL,
    note_nlp_concept_id integer,
    note_nlp_source_concept_id integer,
    nlp_system character varying(250),
    nlp_date date NOT NULL,
    nlp_datetime timestamp without time zone,
    term_exists character varying(1),
    term_temporal character varying(50),
    term_modifiers character varying(2000)
);


ALTER TABLE omopcdm.note_nlp OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 24627)
-- Name: observation; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.observation (
    observation_id integer NOT NULL,
    person_id integer NOT NULL,
    observation_concept_id integer NOT NULL,
    observation_date date NOT NULL,
    observation_datetime timestamp without time zone,
    observation_type_concept_id integer NOT NULL,
    value_as_number numeric,
    value_as_string character varying(60),
    value_as_concept_id integer,
    qualifier_concept_id integer,
    unit_concept_id integer,
    provider_id integer,
    visit_occurrence_id integer,
    visit_detail_id integer,
    observation_source_value character varying(50),
    observation_source_concept_id integer,
    unit_source_value character varying(50),
    qualifier_source_value character varying(50),
    value_source_value character varying(50),
    observation_event_id integer,
    obs_event_field_concept_id integer
);


ALTER TABLE omopcdm.observation OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 24594)
-- Name: observation_period; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.observation_period (
    observation_period_id integer NOT NULL,
    person_id integer NOT NULL,
    observation_period_start_date date NOT NULL,
    observation_period_end_date date NOT NULL,
    period_type_concept_id integer NOT NULL
);


ALTER TABLE omopcdm.observation_period OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 24669)
-- Name: payer_plan_period; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.payer_plan_period (
    payer_plan_period_id integer NOT NULL,
    person_id integer NOT NULL,
    payer_plan_period_start_date date NOT NULL,
    payer_plan_period_end_date date NOT NULL,
    payer_concept_id integer,
    payer_source_value character varying(50),
    payer_source_concept_id integer,
    plan_concept_id integer,
    plan_source_value character varying(50),
    plan_source_concept_id integer,
    sponsor_concept_id integer,
    sponsor_source_value character varying(50),
    sponsor_source_concept_id integer,
    family_source_value character varying(50),
    stop_reason_concept_id integer,
    stop_reason_source_value character varying(50),
    stop_reason_source_concept_id integer
);


ALTER TABLE omopcdm.payer_plan_period OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 24591)
-- Name: person; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.person (
    person_id integer NOT NULL,
    gender_concept_id integer NOT NULL,
    year_of_birth integer NOT NULL,
    month_of_birth integer,
    day_of_birth integer,
    birth_datetime timestamp without time zone,
    race_concept_id integer NOT NULL,
    ethnicity_concept_id integer NOT NULL,
    location_id integer,
    provider_id integer,
    care_site_id integer,
    person_source_value character varying(50),
    gender_source_value character varying(50),
    gender_source_concept_id integer,
    race_source_value character varying(50),
    race_source_concept_id integer,
    ethnicity_source_value character varying(50),
    ethnicity_source_concept_id integer
);


ALTER TABLE omopcdm.person OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 24612)
-- Name: procedure_occurrence; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.procedure_occurrence (
    procedure_occurrence_id integer NOT NULL,
    person_id integer NOT NULL,
    procedure_concept_id integer NOT NULL,
    procedure_date date NOT NULL,
    procedure_datetime timestamp without time zone,
    procedure_end_date date,
    procedure_end_datetime timestamp without time zone,
    procedure_type_concept_id integer NOT NULL,
    modifier_concept_id integer,
    quantity integer,
    provider_id integer,
    visit_occurrence_id integer,
    visit_detail_id integer,
    procedure_source_value character varying(50),
    procedure_source_concept_id integer,
    modifier_source_value character varying(50)
);


ALTER TABLE omopcdm.procedure_occurrence OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 24666)
-- Name: provider; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.provider (
    provider_id integer NOT NULL,
    provider_name character varying(255),
    npi character varying(20),
    dea character varying(20),
    specialty_concept_id integer,
    care_site_id integer,
    year_of_birth integer,
    gender_concept_id integer,
    provider_source_value character varying(50),
    specialty_source_value character varying(50),
    specialty_source_concept_id integer,
    gender_source_value character varying(50),
    gender_source_concept_id integer
);


ALTER TABLE omopcdm.provider OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 24726)
-- Name: relationship; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.relationship (
    relationship_id character varying(20) NOT NULL,
    relationship_name character varying(255) NOT NULL,
    is_hierarchical character varying(1) NOT NULL,
    defines_ancestry character varying(1) NOT NULL,
    reverse_relationship_id character varying(20) NOT NULL,
    relationship_concept_id integer NOT NULL
);


ALTER TABLE omopcdm.relationship OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 24738)
-- Name: source_to_concept_map; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.source_to_concept_map (
    source_code character varying(50) NOT NULL,
    source_concept_id integer NOT NULL,
    source_vocabulary_id character varying(20) NOT NULL,
    source_code_description character varying(255),
    target_concept_id integer NOT NULL,
    target_vocabulary_id character varying(20) NOT NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason character varying(1)
);


ALTER TABLE omopcdm.source_to_concept_map OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 24648)
-- Name: specimen; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.specimen (
    specimen_id integer NOT NULL,
    person_id integer NOT NULL,
    specimen_concept_id integer NOT NULL,
    specimen_type_concept_id integer NOT NULL,
    specimen_date date NOT NULL,
    specimen_datetime timestamp without time zone,
    quantity numeric,
    unit_concept_id integer,
    anatomic_site_concept_id integer,
    disease_status_concept_id integer,
    specimen_source_id character varying(50),
    specimen_source_value character varying(50),
    unit_source_value character varying(50),
    anatomic_site_source_value character varying(50),
    disease_status_source_value character varying(50)
);


ALTER TABLE omopcdm.specimen OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 24600)
-- Name: visit_detail; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.visit_detail (
    visit_detail_id integer NOT NULL,
    person_id integer NOT NULL,
    visit_detail_concept_id integer NOT NULL,
    visit_detail_start_date date NOT NULL,
    visit_detail_start_datetime timestamp without time zone,
    visit_detail_end_date date NOT NULL,
    visit_detail_end_datetime timestamp without time zone,
    visit_detail_type_concept_id integer NOT NULL,
    provider_id integer,
    care_site_id integer,
    visit_detail_source_value character varying(50),
    visit_detail_source_concept_id integer,
    admitted_from_concept_id integer,
    admitted_from_source_value character varying(50),
    discharged_to_source_value character varying(50),
    discharged_to_concept_id integer,
    preceding_visit_detail_id integer,
    parent_visit_detail_id integer,
    visit_occurrence_id integer NOT NULL
);


ALTER TABLE omopcdm.visit_detail OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 24597)
-- Name: visit_occurrence; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.visit_occurrence (
    visit_occurrence_id integer NOT NULL,
    person_id integer NOT NULL,
    visit_concept_id integer NOT NULL,
    visit_start_date date NOT NULL,
    visit_start_datetime timestamp without time zone,
    visit_end_date date NOT NULL,
    visit_end_datetime timestamp without time zone,
    visit_type_concept_id integer NOT NULL,
    provider_id integer,
    care_site_id integer,
    visit_source_value character varying(50),
    visit_source_concept_id integer,
    admitted_from_concept_id integer,
    admitted_from_source_value character varying(50),
    discharged_to_concept_id integer,
    discharged_to_source_value character varying(50),
    preceding_visit_occurrence_id integer
);


ALTER TABLE omopcdm.visit_occurrence OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 24711)
-- Name: vocabulary; Type: TABLE; Schema: omopcdm; Owner: postgres
--

CREATE TABLE omopcdm.vocabulary (
    vocabulary_id character varying(20) NOT NULL,
    vocabulary_name character varying(255) NOT NULL,
    vocabulary_reference character varying(255),
    vocabulary_version character varying(255),
    vocabulary_concept_id integer NOT NULL
);


ALTER TABLE omopcdm.vocabulary OWNER TO postgres;

--
-- TOC entry 3091 (class 2606 OID 24794)
-- Name: care_site xpk_care_site; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.care_site
    ADD CONSTRAINT xpk_care_site PRIMARY KEY (care_site_id);


--
-- TOC entry 3124 (class 2606 OID 24812)
-- Name: concept xpk_concept; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept
    ADD CONSTRAINT xpk_concept PRIMARY KEY (concept_id);


--
-- TOC entry 3133 (class 2606 OID 24818)
-- Name: concept_class xpk_concept_class; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept_class
    ADD CONSTRAINT xpk_concept_class PRIMARY KEY (concept_class_id);


--
-- TOC entry 3112 (class 2606 OID 24806)
-- Name: condition_era xpk_condition_era; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_era
    ADD CONSTRAINT xpk_condition_era PRIMARY KEY (condition_era_id);


--
-- TOC entry 3043 (class 2606 OID 24774)
-- Name: condition_occurrence xpk_condition_occurrence; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_occurrence
    ADD CONSTRAINT xpk_condition_occurrence PRIMARY KEY (condition_occurrence_id);


--
-- TOC entry 3100 (class 2606 OID 24800)
-- Name: cost xpk_cost; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.cost
    ADD CONSTRAINT xpk_cost PRIMARY KEY (cost_id);


--
-- TOC entry 3058 (class 2606 OID 24780)
-- Name: device_exposure xpk_device_exposure; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.device_exposure
    ADD CONSTRAINT xpk_device_exposure PRIMARY KEY (device_exposure_id);


--
-- TOC entry 3130 (class 2606 OID 24816)
-- Name: domain xpk_domain; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.domain
    ADD CONSTRAINT xpk_domain PRIMARY KEY (domain_id);


--
-- TOC entry 3108 (class 2606 OID 24804)
-- Name: dose_era xpk_dose_era; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.dose_era
    ADD CONSTRAINT xpk_dose_era PRIMARY KEY (dose_era_id);


--
-- TOC entry 3104 (class 2606 OID 24802)
-- Name: drug_era xpk_drug_era; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_era
    ADD CONSTRAINT xpk_drug_era PRIMARY KEY (drug_era_id);


--
-- TOC entry 3048 (class 2606 OID 24776)
-- Name: drug_exposure xpk_drug_exposure; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_exposure
    ADD CONSTRAINT xpk_drug_exposure PRIMARY KEY (drug_exposure_id);


--
-- TOC entry 3114 (class 2606 OID 24808)
-- Name: episode xpk_episode; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.episode
    ADD CONSTRAINT xpk_episode PRIMARY KEY (episode_id);


--
-- TOC entry 3088 (class 2606 OID 24792)
-- Name: location xpk_location; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.location
    ADD CONSTRAINT xpk_location PRIMARY KEY (location_id);


--
-- TOC entry 3063 (class 2606 OID 24782)
-- Name: measurement xpk_measurement; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT xpk_measurement PRIMARY KEY (measurement_id);


--
-- TOC entry 3117 (class 2606 OID 24810)
-- Name: metadata xpk_metadata; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.metadata
    ADD CONSTRAINT xpk_metadata PRIMARY KEY (metadata_id);


--
-- TOC entry 3074 (class 2606 OID 24786)
-- Name: note xpk_note; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note
    ADD CONSTRAINT xpk_note PRIMARY KEY (note_id);


--
-- TOC entry 3078 (class 2606 OID 24788)
-- Name: note_nlp xpk_note_nlp; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note_nlp
    ADD CONSTRAINT xpk_note_nlp PRIMARY KEY (note_nlp_id);


--
-- TOC entry 3068 (class 2606 OID 24784)
-- Name: observation xpk_observation; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT xpk_observation PRIMARY KEY (observation_id);


--
-- TOC entry 3029 (class 2606 OID 24768)
-- Name: observation_period xpk_observation_period; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation_period
    ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id);


--
-- TOC entry 3097 (class 2606 OID 24798)
-- Name: payer_plan_period xpk_payer_plan_period; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.payer_plan_period
    ADD CONSTRAINT xpk_payer_plan_period PRIMARY KEY (payer_plan_period_id);


--
-- TOC entry 3026 (class 2606 OID 24766)
-- Name: person xpk_person; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.person
    ADD CONSTRAINT xpk_person PRIMARY KEY (person_id);


--
-- TOC entry 3053 (class 2606 OID 24778)
-- Name: procedure_occurrence xpk_procedure_occurrence; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.procedure_occurrence
    ADD CONSTRAINT xpk_procedure_occurrence PRIMARY KEY (procedure_occurrence_id);


--
-- TOC entry 3094 (class 2606 OID 24796)
-- Name: provider xpk_provider; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.provider
    ADD CONSTRAINT xpk_provider PRIMARY KEY (provider_id);


--
-- TOC entry 3139 (class 2606 OID 24820)
-- Name: relationship xpk_relationship; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.relationship
    ADD CONSTRAINT xpk_relationship PRIMARY KEY (relationship_id);


--
-- TOC entry 3082 (class 2606 OID 24790)
-- Name: specimen xpk_specimen; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.specimen
    ADD CONSTRAINT xpk_specimen PRIMARY KEY (specimen_id);


--
-- TOC entry 3038 (class 2606 OID 24772)
-- Name: visit_detail xpk_visit_detail; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id);


--
-- TOC entry 3033 (class 2606 OID 24770)
-- Name: visit_occurrence xpk_visit_occurrence; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_occurrence
    ADD CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id);


--
-- TOC entry 3127 (class 2606 OID 24814)
-- Name: vocabulary xpk_vocabulary; Type: CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.vocabulary
    ADD CONSTRAINT xpk_vocabulary PRIMARY KEY (vocabulary_id);


--
-- TOC entry 3089 (class 1259 OID 24957)
-- Name: idx_care_site_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_care_site_id_1 ON omopcdm.care_site USING btree (care_site_id);

ALTER TABLE omopcdm.care_site CLUSTER ON idx_care_site_id_1;


--
-- TOC entry 3141 (class 1259 OID 25061)
-- Name: idx_concept_ancestor_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_ancestor_id_1 ON omopcdm.concept_ancestor USING btree (ancestor_concept_id);

ALTER TABLE omopcdm.concept_ancestor CLUSTER ON idx_concept_ancestor_id_1;


--
-- TOC entry 3142 (class 1259 OID 25066)
-- Name: idx_concept_ancestor_id_2; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_ancestor_id_2 ON omopcdm.concept_ancestor USING btree (descendant_concept_id);


--
-- TOC entry 3131 (class 1259 OID 25034)
-- Name: idx_concept_class_class_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_class_class_id ON omopcdm.concept_class USING btree (concept_class_id);

ALTER TABLE omopcdm.concept_class CLUSTER ON idx_concept_class_class_id;


--
-- TOC entry 3118 (class 1259 OID 25018)
-- Name: idx_concept_class_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_class_id ON omopcdm.concept USING btree (concept_class_id);


--
-- TOC entry 3119 (class 1259 OID 25015)
-- Name: idx_concept_code; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_code ON omopcdm.concept USING btree (concept_code);


--
-- TOC entry 3120 (class 1259 OID 25009)
-- Name: idx_concept_concept_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_concept_id ON omopcdm.concept USING btree (concept_id);

ALTER TABLE omopcdm.concept CLUSTER ON idx_concept_concept_id;


--
-- TOC entry 3121 (class 1259 OID 25017)
-- Name: idx_concept_domain_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_domain_id ON omopcdm.concept USING btree (domain_id);


--
-- TOC entry 3134 (class 1259 OID 25040)
-- Name: idx_concept_relationship_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_relationship_id_1 ON omopcdm.concept_relationship USING btree (concept_id_1);

ALTER TABLE omopcdm.concept_relationship CLUSTER ON idx_concept_relationship_id_1;


--
-- TOC entry 3135 (class 1259 OID 25045)
-- Name: idx_concept_relationship_id_2; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_relationship_id_2 ON omopcdm.concept_relationship USING btree (concept_id_2);


--
-- TOC entry 3136 (class 1259 OID 25046)
-- Name: idx_concept_relationship_id_3; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_relationship_id_3 ON omopcdm.concept_relationship USING btree (relationship_id);


--
-- TOC entry 3140 (class 1259 OID 25053)
-- Name: idx_concept_synonym_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_synonym_id ON omopcdm.concept_synonym USING btree (concept_id);

ALTER TABLE omopcdm.concept_synonym CLUSTER ON idx_concept_synonym_id;


--
-- TOC entry 3122 (class 1259 OID 25016)
-- Name: idx_concept_vocabluary_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_concept_vocabluary_id ON omopcdm.concept USING btree (vocabulary_id);


--
-- TOC entry 3039 (class 1259 OID 24855)
-- Name: idx_condition_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_condition_concept_id_1 ON omopcdm.condition_occurrence USING btree (condition_concept_id);


--
-- TOC entry 3109 (class 1259 OID 24999)
-- Name: idx_condition_era_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_condition_era_concept_id_1 ON omopcdm.condition_era USING btree (condition_concept_id);


--
-- TOC entry 3110 (class 1259 OID 24993)
-- Name: idx_condition_era_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_condition_era_person_id_1 ON omopcdm.condition_era USING btree (person_id);

ALTER TABLE omopcdm.condition_era CLUSTER ON idx_condition_era_person_id_1;


--
-- TOC entry 3040 (class 1259 OID 24849)
-- Name: idx_condition_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_condition_person_id_1 ON omopcdm.condition_occurrence USING btree (person_id);

ALTER TABLE omopcdm.condition_occurrence CLUSTER ON idx_condition_person_id_1;


--
-- TOC entry 3041 (class 1259 OID 24856)
-- Name: idx_condition_visit_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_condition_visit_id_1 ON omopcdm.condition_occurrence USING btree (visit_occurrence_id);


--
-- TOC entry 3098 (class 1259 OID 24975)
-- Name: idx_cost_event_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_cost_event_id ON omopcdm.cost USING btree (cost_event_id);


--
-- TOC entry 3069 (class 1259 OID 24909)
-- Name: idx_death_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_death_person_id_1 ON omopcdm.death USING btree (person_id);

ALTER TABLE omopcdm.death CLUSTER ON idx_death_person_id_1;


--
-- TOC entry 3054 (class 1259 OID 24885)
-- Name: idx_device_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_device_concept_id_1 ON omopcdm.device_exposure USING btree (device_concept_id);


--
-- TOC entry 3055 (class 1259 OID 24876)
-- Name: idx_device_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_device_person_id_1 ON omopcdm.device_exposure USING btree (person_id);

ALTER TABLE omopcdm.device_exposure CLUSTER ON idx_device_person_id_1;


--
-- TOC entry 3056 (class 1259 OID 24886)
-- Name: idx_device_visit_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_device_visit_id_1 ON omopcdm.device_exposure USING btree (visit_occurrence_id);


--
-- TOC entry 3128 (class 1259 OID 25028)
-- Name: idx_domain_domain_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_domain_domain_id ON omopcdm.domain USING btree (domain_id);

ALTER TABLE omopcdm.domain CLUSTER ON idx_domain_domain_id;


--
-- TOC entry 3105 (class 1259 OID 24992)
-- Name: idx_dose_era_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_dose_era_concept_id_1 ON omopcdm.dose_era USING btree (drug_concept_id);


--
-- TOC entry 3106 (class 1259 OID 24983)
-- Name: idx_dose_era_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_dose_era_person_id_1 ON omopcdm.dose_era USING btree (person_id);

ALTER TABLE omopcdm.dose_era CLUSTER ON idx_dose_era_person_id_1;


--
-- TOC entry 3044 (class 1259 OID 24866)
-- Name: idx_drug_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_drug_concept_id_1 ON omopcdm.drug_exposure USING btree (drug_concept_id);


--
-- TOC entry 3101 (class 1259 OID 24982)
-- Name: idx_drug_era_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_drug_era_concept_id_1 ON omopcdm.drug_era USING btree (drug_concept_id);


--
-- TOC entry 3102 (class 1259 OID 24976)
-- Name: idx_drug_era_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_drug_era_person_id_1 ON omopcdm.drug_era USING btree (person_id);

ALTER TABLE omopcdm.drug_era CLUSTER ON idx_drug_era_person_id_1;


--
-- TOC entry 3045 (class 1259 OID 24857)
-- Name: idx_drug_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_drug_person_id_1 ON omopcdm.drug_exposure USING btree (person_id);

ALTER TABLE omopcdm.drug_exposure CLUSTER ON idx_drug_person_id_1;


--
-- TOC entry 3147 (class 1259 OID 25075)
-- Name: idx_drug_strength_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_drug_strength_id_1 ON omopcdm.drug_strength USING btree (drug_concept_id);

ALTER TABLE omopcdm.drug_strength CLUSTER ON idx_drug_strength_id_1;


--
-- TOC entry 3148 (class 1259 OID 25083)
-- Name: idx_drug_strength_id_2; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_drug_strength_id_2 ON omopcdm.drug_strength USING btree (ingredient_concept_id);


--
-- TOC entry 3046 (class 1259 OID 24867)
-- Name: idx_drug_visit_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_drug_visit_id_1 ON omopcdm.drug_exposure USING btree (visit_occurrence_id);


--
-- TOC entry 3083 (class 1259 OID 24945)
-- Name: idx_fact_relationship_id1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_fact_relationship_id1 ON omopcdm.fact_relationship USING btree (domain_concept_id_1);


--
-- TOC entry 3084 (class 1259 OID 24946)
-- Name: idx_fact_relationship_id2; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_fact_relationship_id2 ON omopcdm.fact_relationship USING btree (domain_concept_id_2);


--
-- TOC entry 3085 (class 1259 OID 24947)
-- Name: idx_fact_relationship_id3; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_fact_relationship_id3 ON omopcdm.fact_relationship USING btree (relationship_concept_id);


--
-- TOC entry 3023 (class 1259 OID 24827)
-- Name: idx_gender; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_gender ON omopcdm.person USING btree (gender_concept_id);


--
-- TOC entry 3086 (class 1259 OID 24948)
-- Name: idx_location_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_location_id_1 ON omopcdm.location USING btree (location_id);

ALTER TABLE omopcdm.location CLUSTER ON idx_location_id_1;


--
-- TOC entry 3059 (class 1259 OID 24896)
-- Name: idx_measurement_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_measurement_concept_id_1 ON omopcdm.measurement USING btree (measurement_concept_id);


--
-- TOC entry 3060 (class 1259 OID 24887)
-- Name: idx_measurement_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_measurement_person_id_1 ON omopcdm.measurement USING btree (person_id);

ALTER TABLE omopcdm.measurement CLUSTER ON idx_measurement_person_id_1;


--
-- TOC entry 3061 (class 1259 OID 24897)
-- Name: idx_measurement_visit_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_measurement_visit_id_1 ON omopcdm.measurement USING btree (visit_occurrence_id);


--
-- TOC entry 3115 (class 1259 OID 25000)
-- Name: idx_metadata_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_metadata_concept_id_1 ON omopcdm.metadata USING btree (metadata_concept_id);

ALTER TABLE omopcdm.metadata CLUSTER ON idx_metadata_concept_id_1;


--
-- TOC entry 3070 (class 1259 OID 24923)
-- Name: idx_note_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_note_concept_id_1 ON omopcdm.note USING btree (note_type_concept_id);


--
-- TOC entry 3075 (class 1259 OID 24934)
-- Name: idx_note_nlp_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_note_nlp_concept_id_1 ON omopcdm.note_nlp USING btree (note_nlp_concept_id);


--
-- TOC entry 3076 (class 1259 OID 24925)
-- Name: idx_note_nlp_note_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_note_nlp_note_id_1 ON omopcdm.note_nlp USING btree (note_id);

ALTER TABLE omopcdm.note_nlp CLUSTER ON idx_note_nlp_note_id_1;


--
-- TOC entry 3071 (class 1259 OID 24914)
-- Name: idx_note_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_note_person_id_1 ON omopcdm.note USING btree (person_id);

ALTER TABLE omopcdm.note CLUSTER ON idx_note_person_id_1;


--
-- TOC entry 3072 (class 1259 OID 24924)
-- Name: idx_note_visit_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_note_visit_id_1 ON omopcdm.note USING btree (visit_occurrence_id);


--
-- TOC entry 3064 (class 1259 OID 24907)
-- Name: idx_observation_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_observation_concept_id_1 ON omopcdm.observation USING btree (observation_concept_id);


--
-- TOC entry 3027 (class 1259 OID 24828)
-- Name: idx_observation_period_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_observation_period_id_1 ON omopcdm.observation_period USING btree (person_id);

ALTER TABLE omopcdm.observation_period CLUSTER ON idx_observation_period_id_1;


--
-- TOC entry 3065 (class 1259 OID 24898)
-- Name: idx_observation_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_observation_person_id_1 ON omopcdm.observation USING btree (person_id);

ALTER TABLE omopcdm.observation CLUSTER ON idx_observation_person_id_1;


--
-- TOC entry 3066 (class 1259 OID 24908)
-- Name: idx_observation_visit_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_observation_visit_id_1 ON omopcdm.observation USING btree (visit_occurrence_id);


--
-- TOC entry 3095 (class 1259 OID 24969)
-- Name: idx_period_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_period_person_id_1 ON omopcdm.payer_plan_period USING btree (person_id);

ALTER TABLE omopcdm.payer_plan_period CLUSTER ON idx_period_person_id_1;


--
-- TOC entry 3024 (class 1259 OID 24821)
-- Name: idx_person_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_person_id ON omopcdm.person USING btree (person_id);

ALTER TABLE omopcdm.person CLUSTER ON idx_person_id;


--
-- TOC entry 3049 (class 1259 OID 24874)
-- Name: idx_procedure_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_procedure_concept_id_1 ON omopcdm.procedure_occurrence USING btree (procedure_concept_id);


--
-- TOC entry 3050 (class 1259 OID 24868)
-- Name: idx_procedure_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_procedure_person_id_1 ON omopcdm.procedure_occurrence USING btree (person_id);

ALTER TABLE omopcdm.procedure_occurrence CLUSTER ON idx_procedure_person_id_1;


--
-- TOC entry 3051 (class 1259 OID 24875)
-- Name: idx_procedure_visit_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_procedure_visit_id_1 ON omopcdm.procedure_occurrence USING btree (visit_occurrence_id);


--
-- TOC entry 3092 (class 1259 OID 24963)
-- Name: idx_provider_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_provider_id_1 ON omopcdm.provider USING btree (provider_id);

ALTER TABLE omopcdm.provider CLUSTER ON idx_provider_id_1;


--
-- TOC entry 3137 (class 1259 OID 25047)
-- Name: idx_relationship_rel_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_relationship_rel_id ON omopcdm.relationship USING btree (relationship_id);

ALTER TABLE omopcdm.relationship CLUSTER ON idx_relationship_rel_id;


--
-- TOC entry 3143 (class 1259 OID 25072)
-- Name: idx_source_to_concept_map_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_source_to_concept_map_1 ON omopcdm.source_to_concept_map USING btree (source_vocabulary_id);


--
-- TOC entry 3144 (class 1259 OID 25073)
-- Name: idx_source_to_concept_map_2; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_source_to_concept_map_2 ON omopcdm.source_to_concept_map USING btree (target_vocabulary_id);


--
-- TOC entry 3145 (class 1259 OID 25067)
-- Name: idx_source_to_concept_map_3; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_source_to_concept_map_3 ON omopcdm.source_to_concept_map USING btree (target_concept_id);

ALTER TABLE omopcdm.source_to_concept_map CLUSTER ON idx_source_to_concept_map_3;


--
-- TOC entry 3146 (class 1259 OID 25074)
-- Name: idx_source_to_concept_map_c; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_source_to_concept_map_c ON omopcdm.source_to_concept_map USING btree (source_code);


--
-- TOC entry 3079 (class 1259 OID 24944)
-- Name: idx_specimen_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_specimen_concept_id_1 ON omopcdm.specimen USING btree (specimen_concept_id);


--
-- TOC entry 3080 (class 1259 OID 24935)
-- Name: idx_specimen_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_specimen_person_id_1 ON omopcdm.specimen USING btree (person_id);

ALTER TABLE omopcdm.specimen CLUSTER ON idx_specimen_person_id_1;


--
-- TOC entry 3030 (class 1259 OID 24840)
-- Name: idx_visit_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_visit_concept_id_1 ON omopcdm.visit_occurrence USING btree (visit_concept_id);


--
-- TOC entry 3034 (class 1259 OID 24847)
-- Name: idx_visit_det_concept_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_visit_det_concept_id_1 ON omopcdm.visit_detail USING btree (visit_detail_concept_id);


--
-- TOC entry 3035 (class 1259 OID 24848)
-- Name: idx_visit_det_occ_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_visit_det_occ_id ON omopcdm.visit_detail USING btree (visit_occurrence_id);


--
-- TOC entry 3036 (class 1259 OID 24841)
-- Name: idx_visit_det_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_visit_det_person_id_1 ON omopcdm.visit_detail USING btree (person_id);

ALTER TABLE omopcdm.visit_detail CLUSTER ON idx_visit_det_person_id_1;


--
-- TOC entry 3031 (class 1259 OID 24834)
-- Name: idx_visit_person_id_1; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_visit_person_id_1 ON omopcdm.visit_occurrence USING btree (person_id);

ALTER TABLE omopcdm.visit_occurrence CLUSTER ON idx_visit_person_id_1;


--
-- TOC entry 3125 (class 1259 OID 25019)
-- Name: idx_vocabulary_vocabulary_id; Type: INDEX; Schema: omopcdm; Owner: postgres
--

CREATE INDEX idx_vocabulary_vocabulary_id ON omopcdm.vocabulary USING btree (vocabulary_id);

ALTER TABLE omopcdm.vocabulary CLUSTER ON idx_vocabulary_vocabulary_id;


--
-- TOC entry 3263 (class 2606 OID 25655)
-- Name: care_site fpk_care_site_location_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.care_site
    ADD CONSTRAINT fpk_care_site_location_id FOREIGN KEY (location_id) REFERENCES omopcdm.location(location_id);


--
-- TOC entry 3262 (class 2606 OID 25650)
-- Name: care_site fpk_care_site_place_of_service_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.care_site
    ADD CONSTRAINT fpk_care_site_place_of_service_concept_id FOREIGN KEY (place_of_service_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3300 (class 2606 OID 25840)
-- Name: cdm_source fpk_cdm_source_cdm_version_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.cdm_source
    ADD CONSTRAINT fpk_cdm_source_cdm_version_concept_id FOREIGN KEY (cdm_version_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3323 (class 2606 OID 25955)
-- Name: cohort_definition fpk_cohort_definition_definition_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.cohort_definition
    ADD CONSTRAINT fpk_cohort_definition_definition_type_concept_id FOREIGN KEY (definition_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3324 (class 2606 OID 25960)
-- Name: cohort_definition fpk_cohort_definition_subject_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.cohort_definition
    ADD CONSTRAINT fpk_cohort_definition_subject_concept_id FOREIGN KEY (subject_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3313 (class 2606 OID 25905)
-- Name: concept_ancestor fpk_concept_ancestor_ancestor_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept_ancestor
    ADD CONSTRAINT fpk_concept_ancestor_ancestor_concept_id FOREIGN KEY (ancestor_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3314 (class 2606 OID 25910)
-- Name: concept_ancestor fpk_concept_ancestor_descendant_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept_ancestor
    ADD CONSTRAINT fpk_concept_ancestor_descendant_concept_id FOREIGN KEY (descendant_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3306 (class 2606 OID 25870)
-- Name: concept_class fpk_concept_class_concept_class_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept_class
    ADD CONSTRAINT fpk_concept_class_concept_class_concept_id FOREIGN KEY (concept_class_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3303 (class 2606 OID 25855)
-- Name: concept fpk_concept_concept_class_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept
    ADD CONSTRAINT fpk_concept_concept_class_id FOREIGN KEY (concept_class_id) REFERENCES omopcdm.concept_class(concept_class_id);


--
-- TOC entry 3301 (class 2606 OID 25845)
-- Name: concept fpk_concept_domain_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept
    ADD CONSTRAINT fpk_concept_domain_id FOREIGN KEY (domain_id) REFERENCES omopcdm.domain(domain_id);


--
-- TOC entry 3307 (class 2606 OID 25875)
-- Name: concept_relationship fpk_concept_relationship_concept_id_1; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept_relationship
    ADD CONSTRAINT fpk_concept_relationship_concept_id_1 FOREIGN KEY (concept_id_1) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3308 (class 2606 OID 25880)
-- Name: concept_relationship fpk_concept_relationship_concept_id_2; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept_relationship
    ADD CONSTRAINT fpk_concept_relationship_concept_id_2 FOREIGN KEY (concept_id_2) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3309 (class 2606 OID 25885)
-- Name: concept_relationship fpk_concept_relationship_relationship_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept_relationship
    ADD CONSTRAINT fpk_concept_relationship_relationship_id FOREIGN KEY (relationship_id) REFERENCES omopcdm.relationship(relationship_id);


--
-- TOC entry 3311 (class 2606 OID 25895)
-- Name: concept_synonym fpk_concept_synonym_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept_synonym
    ADD CONSTRAINT fpk_concept_synonym_concept_id FOREIGN KEY (concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3312 (class 2606 OID 25900)
-- Name: concept_synonym fpk_concept_synonym_language_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept_synonym
    ADD CONSTRAINT fpk_concept_synonym_language_concept_id FOREIGN KEY (language_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3302 (class 2606 OID 25850)
-- Name: concept fpk_concept_vocabulary_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.concept
    ADD CONSTRAINT fpk_concept_vocabulary_id FOREIGN KEY (vocabulary_id) REFERENCES omopcdm.vocabulary(vocabulary_id);


--
-- TOC entry 3289 (class 2606 OID 25785)
-- Name: condition_era fpk_condition_era_condition_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_era
    ADD CONSTRAINT fpk_condition_era_condition_concept_id FOREIGN KEY (condition_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3288 (class 2606 OID 25780)
-- Name: condition_era fpk_condition_era_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_era
    ADD CONSTRAINT fpk_condition_era_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3181 (class 2606 OID 25245)
-- Name: condition_occurrence fpk_condition_occurrence_condition_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_occurrence
    ADD CONSTRAINT fpk_condition_occurrence_condition_concept_id FOREIGN KEY (condition_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3187 (class 2606 OID 25275)
-- Name: condition_occurrence fpk_condition_occurrence_condition_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_occurrence
    ADD CONSTRAINT fpk_condition_occurrence_condition_source_concept_id FOREIGN KEY (condition_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3183 (class 2606 OID 25255)
-- Name: condition_occurrence fpk_condition_occurrence_condition_status_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_occurrence
    ADD CONSTRAINT fpk_condition_occurrence_condition_status_concept_id FOREIGN KEY (condition_status_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3182 (class 2606 OID 25250)
-- Name: condition_occurrence fpk_condition_occurrence_condition_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_occurrence
    ADD CONSTRAINT fpk_condition_occurrence_condition_type_concept_id FOREIGN KEY (condition_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3180 (class 2606 OID 25240)
-- Name: condition_occurrence fpk_condition_occurrence_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_occurrence
    ADD CONSTRAINT fpk_condition_occurrence_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3184 (class 2606 OID 25260)
-- Name: condition_occurrence fpk_condition_occurrence_provider_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_occurrence
    ADD CONSTRAINT fpk_condition_occurrence_provider_id FOREIGN KEY (provider_id) REFERENCES omopcdm.provider(provider_id);


--
-- TOC entry 3186 (class 2606 OID 25270)
-- Name: condition_occurrence fpk_condition_occurrence_visit_detail_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_occurrence
    ADD CONSTRAINT fpk_condition_occurrence_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES omopcdm.visit_detail(visit_detail_id);


--
-- TOC entry 3185 (class 2606 OID 25265)
-- Name: condition_occurrence fpk_condition_occurrence_visit_occurrence_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.condition_occurrence
    ADD CONSTRAINT fpk_condition_occurrence_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES omopcdm.visit_occurrence(visit_occurrence_id);


--
-- TOC entry 3278 (class 2606 OID 25730)
-- Name: cost fpk_cost_cost_domain_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.cost
    ADD CONSTRAINT fpk_cost_cost_domain_id FOREIGN KEY (cost_domain_id) REFERENCES omopcdm.domain(domain_id);


--
-- TOC entry 3279 (class 2606 OID 25735)
-- Name: cost fpk_cost_cost_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.cost
    ADD CONSTRAINT fpk_cost_cost_type_concept_id FOREIGN KEY (cost_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3280 (class 2606 OID 25740)
-- Name: cost fpk_cost_currency_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.cost
    ADD CONSTRAINT fpk_cost_currency_concept_id FOREIGN KEY (currency_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3282 (class 2606 OID 25750)
-- Name: cost fpk_cost_drg_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.cost
    ADD CONSTRAINT fpk_cost_drg_concept_id FOREIGN KEY (drg_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3281 (class 2606 OID 25745)
-- Name: cost fpk_cost_revenue_code_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.cost
    ADD CONSTRAINT fpk_cost_revenue_code_concept_id FOREIGN KEY (revenue_code_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3238 (class 2606 OID 25530)
-- Name: death fpk_death_cause_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.death
    ADD CONSTRAINT fpk_death_cause_concept_id FOREIGN KEY (cause_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3239 (class 2606 OID 25535)
-- Name: death fpk_death_cause_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.death
    ADD CONSTRAINT fpk_death_cause_source_concept_id FOREIGN KEY (cause_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3237 (class 2606 OID 25525)
-- Name: death fpk_death_death_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.death
    ADD CONSTRAINT fpk_death_death_type_concept_id FOREIGN KEY (death_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3236 (class 2606 OID 25520)
-- Name: death fpk_death_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.death
    ADD CONSTRAINT fpk_death_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3205 (class 2606 OID 25365)
-- Name: device_exposure fpk_device_exposure_device_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.device_exposure
    ADD CONSTRAINT fpk_device_exposure_device_concept_id FOREIGN KEY (device_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3210 (class 2606 OID 25390)
-- Name: device_exposure fpk_device_exposure_device_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.device_exposure
    ADD CONSTRAINT fpk_device_exposure_device_source_concept_id FOREIGN KEY (device_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3206 (class 2606 OID 25370)
-- Name: device_exposure fpk_device_exposure_device_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.device_exposure
    ADD CONSTRAINT fpk_device_exposure_device_type_concept_id FOREIGN KEY (device_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3204 (class 2606 OID 25360)
-- Name: device_exposure fpk_device_exposure_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.device_exposure
    ADD CONSTRAINT fpk_device_exposure_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3207 (class 2606 OID 25375)
-- Name: device_exposure fpk_device_exposure_provider_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.device_exposure
    ADD CONSTRAINT fpk_device_exposure_provider_id FOREIGN KEY (provider_id) REFERENCES omopcdm.provider(provider_id);


--
-- TOC entry 3211 (class 2606 OID 25395)
-- Name: device_exposure fpk_device_exposure_unit_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.device_exposure
    ADD CONSTRAINT fpk_device_exposure_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3212 (class 2606 OID 25400)
-- Name: device_exposure fpk_device_exposure_unit_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.device_exposure
    ADD CONSTRAINT fpk_device_exposure_unit_source_concept_id FOREIGN KEY (unit_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3209 (class 2606 OID 25385)
-- Name: device_exposure fpk_device_exposure_visit_detail_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.device_exposure
    ADD CONSTRAINT fpk_device_exposure_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES omopcdm.visit_detail(visit_detail_id);


--
-- TOC entry 3208 (class 2606 OID 25380)
-- Name: device_exposure fpk_device_exposure_visit_occurrence_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.device_exposure
    ADD CONSTRAINT fpk_device_exposure_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES omopcdm.visit_occurrence(visit_occurrence_id);


--
-- TOC entry 3305 (class 2606 OID 25865)
-- Name: domain fpk_domain_domain_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.domain
    ADD CONSTRAINT fpk_domain_domain_concept_id FOREIGN KEY (domain_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3286 (class 2606 OID 25770)
-- Name: dose_era fpk_dose_era_drug_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.dose_era
    ADD CONSTRAINT fpk_dose_era_drug_concept_id FOREIGN KEY (drug_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3285 (class 2606 OID 25765)
-- Name: dose_era fpk_dose_era_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.dose_era
    ADD CONSTRAINT fpk_dose_era_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3287 (class 2606 OID 25775)
-- Name: dose_era fpk_dose_era_unit_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.dose_era
    ADD CONSTRAINT fpk_dose_era_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3284 (class 2606 OID 25760)
-- Name: drug_era fpk_drug_era_drug_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_era
    ADD CONSTRAINT fpk_drug_era_drug_concept_id FOREIGN KEY (drug_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3283 (class 2606 OID 25755)
-- Name: drug_era fpk_drug_era_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_era
    ADD CONSTRAINT fpk_drug_era_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3189 (class 2606 OID 25285)
-- Name: drug_exposure fpk_drug_exposure_drug_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_exposure
    ADD CONSTRAINT fpk_drug_exposure_drug_concept_id FOREIGN KEY (drug_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3195 (class 2606 OID 25315)
-- Name: drug_exposure fpk_drug_exposure_drug_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_exposure
    ADD CONSTRAINT fpk_drug_exposure_drug_source_concept_id FOREIGN KEY (drug_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3190 (class 2606 OID 25290)
-- Name: drug_exposure fpk_drug_exposure_drug_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_exposure
    ADD CONSTRAINT fpk_drug_exposure_drug_type_concept_id FOREIGN KEY (drug_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3188 (class 2606 OID 25280)
-- Name: drug_exposure fpk_drug_exposure_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_exposure
    ADD CONSTRAINT fpk_drug_exposure_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3192 (class 2606 OID 25300)
-- Name: drug_exposure fpk_drug_exposure_provider_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_exposure
    ADD CONSTRAINT fpk_drug_exposure_provider_id FOREIGN KEY (provider_id) REFERENCES omopcdm.provider(provider_id);


--
-- TOC entry 3191 (class 2606 OID 25295)
-- Name: drug_exposure fpk_drug_exposure_route_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_exposure
    ADD CONSTRAINT fpk_drug_exposure_route_concept_id FOREIGN KEY (route_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3194 (class 2606 OID 25310)
-- Name: drug_exposure fpk_drug_exposure_visit_detail_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_exposure
    ADD CONSTRAINT fpk_drug_exposure_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES omopcdm.visit_detail(visit_detail_id);


--
-- TOC entry 3193 (class 2606 OID 25305)
-- Name: drug_exposure fpk_drug_exposure_visit_occurrence_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_exposure
    ADD CONSTRAINT fpk_drug_exposure_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES omopcdm.visit_occurrence(visit_occurrence_id);


--
-- TOC entry 3320 (class 2606 OID 25940)
-- Name: drug_strength fpk_drug_strength_amount_unit_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_strength
    ADD CONSTRAINT fpk_drug_strength_amount_unit_concept_id FOREIGN KEY (amount_unit_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3322 (class 2606 OID 25950)
-- Name: drug_strength fpk_drug_strength_denominator_unit_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_strength
    ADD CONSTRAINT fpk_drug_strength_denominator_unit_concept_id FOREIGN KEY (denominator_unit_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3318 (class 2606 OID 25930)
-- Name: drug_strength fpk_drug_strength_drug_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_strength
    ADD CONSTRAINT fpk_drug_strength_drug_concept_id FOREIGN KEY (drug_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3319 (class 2606 OID 25935)
-- Name: drug_strength fpk_drug_strength_ingredient_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_strength
    ADD CONSTRAINT fpk_drug_strength_ingredient_concept_id FOREIGN KEY (ingredient_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3321 (class 2606 OID 25945)
-- Name: drug_strength fpk_drug_strength_numerator_unit_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.drug_strength
    ADD CONSTRAINT fpk_drug_strength_numerator_unit_concept_id FOREIGN KEY (numerator_unit_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3291 (class 2606 OID 25795)
-- Name: episode fpk_episode_episode_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.episode
    ADD CONSTRAINT fpk_episode_episode_concept_id FOREIGN KEY (episode_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3292 (class 2606 OID 25800)
-- Name: episode fpk_episode_episode_object_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.episode
    ADD CONSTRAINT fpk_episode_episode_object_concept_id FOREIGN KEY (episode_object_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3294 (class 2606 OID 25810)
-- Name: episode fpk_episode_episode_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.episode
    ADD CONSTRAINT fpk_episode_episode_source_concept_id FOREIGN KEY (episode_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3293 (class 2606 OID 25805)
-- Name: episode fpk_episode_episode_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.episode
    ADD CONSTRAINT fpk_episode_episode_type_concept_id FOREIGN KEY (episode_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3296 (class 2606 OID 25820)
-- Name: episode_event fpk_episode_event_episode_event_field_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.episode_event
    ADD CONSTRAINT fpk_episode_event_episode_event_field_concept_id FOREIGN KEY (episode_event_field_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3295 (class 2606 OID 25815)
-- Name: episode_event fpk_episode_event_episode_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.episode_event
    ADD CONSTRAINT fpk_episode_event_episode_id FOREIGN KEY (episode_id) REFERENCES omopcdm.episode(episode_id);


--
-- TOC entry 3290 (class 2606 OID 25790)
-- Name: episode fpk_episode_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.episode
    ADD CONSTRAINT fpk_episode_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3258 (class 2606 OID 25630)
-- Name: fact_relationship fpk_fact_relationship_domain_concept_id_1; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.fact_relationship
    ADD CONSTRAINT fpk_fact_relationship_domain_concept_id_1 FOREIGN KEY (domain_concept_id_1) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3259 (class 2606 OID 25635)
-- Name: fact_relationship fpk_fact_relationship_domain_concept_id_2; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.fact_relationship
    ADD CONSTRAINT fpk_fact_relationship_domain_concept_id_2 FOREIGN KEY (domain_concept_id_2) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3260 (class 2606 OID 25640)
-- Name: fact_relationship fpk_fact_relationship_relationship_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.fact_relationship
    ADD CONSTRAINT fpk_fact_relationship_relationship_concept_id FOREIGN KEY (relationship_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3261 (class 2606 OID 25645)
-- Name: location fpk_location_country_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.location
    ADD CONSTRAINT fpk_location_country_concept_id FOREIGN KEY (country_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3224 (class 2606 OID 25460)
-- Name: measurement fpk_measurement_meas_event_field_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_meas_event_field_concept_id FOREIGN KEY (meas_event_field_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3214 (class 2606 OID 25410)
-- Name: measurement fpk_measurement_measurement_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_measurement_concept_id FOREIGN KEY (measurement_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3222 (class 2606 OID 25450)
-- Name: measurement fpk_measurement_measurement_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_measurement_source_concept_id FOREIGN KEY (measurement_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3215 (class 2606 OID 25415)
-- Name: measurement fpk_measurement_measurement_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_measurement_type_concept_id FOREIGN KEY (measurement_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3216 (class 2606 OID 25420)
-- Name: measurement fpk_measurement_operator_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_operator_concept_id FOREIGN KEY (operator_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3213 (class 2606 OID 25405)
-- Name: measurement fpk_measurement_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3219 (class 2606 OID 25435)
-- Name: measurement fpk_measurement_provider_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_provider_id FOREIGN KEY (provider_id) REFERENCES omopcdm.provider(provider_id);


--
-- TOC entry 3218 (class 2606 OID 25430)
-- Name: measurement fpk_measurement_unit_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3223 (class 2606 OID 25455)
-- Name: measurement fpk_measurement_unit_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_unit_source_concept_id FOREIGN KEY (unit_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3217 (class 2606 OID 25425)
-- Name: measurement fpk_measurement_value_as_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_value_as_concept_id FOREIGN KEY (value_as_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3221 (class 2606 OID 25445)
-- Name: measurement fpk_measurement_visit_detail_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES omopcdm.visit_detail(visit_detail_id);


--
-- TOC entry 3220 (class 2606 OID 25440)
-- Name: measurement fpk_measurement_visit_occurrence_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.measurement
    ADD CONSTRAINT fpk_measurement_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES omopcdm.visit_occurrence(visit_occurrence_id);


--
-- TOC entry 3297 (class 2606 OID 25825)
-- Name: metadata fpk_metadata_metadata_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.metadata
    ADD CONSTRAINT fpk_metadata_metadata_concept_id FOREIGN KEY (metadata_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3298 (class 2606 OID 25830)
-- Name: metadata fpk_metadata_metadata_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.metadata
    ADD CONSTRAINT fpk_metadata_metadata_type_concept_id FOREIGN KEY (metadata_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3299 (class 2606 OID 25835)
-- Name: metadata fpk_metadata_value_as_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.metadata
    ADD CONSTRAINT fpk_metadata_value_as_concept_id FOREIGN KEY (value_as_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3243 (class 2606 OID 25555)
-- Name: note fpk_note_encoding_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note
    ADD CONSTRAINT fpk_note_encoding_concept_id FOREIGN KEY (encoding_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3244 (class 2606 OID 25560)
-- Name: note fpk_note_language_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note
    ADD CONSTRAINT fpk_note_language_concept_id FOREIGN KEY (language_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3250 (class 2606 OID 25590)
-- Name: note_nlp fpk_note_nlp_note_nlp_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note_nlp
    ADD CONSTRAINT fpk_note_nlp_note_nlp_concept_id FOREIGN KEY (note_nlp_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3251 (class 2606 OID 25595)
-- Name: note_nlp fpk_note_nlp_note_nlp_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note_nlp
    ADD CONSTRAINT fpk_note_nlp_note_nlp_source_concept_id FOREIGN KEY (note_nlp_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3249 (class 2606 OID 25585)
-- Name: note_nlp fpk_note_nlp_section_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note_nlp
    ADD CONSTRAINT fpk_note_nlp_section_concept_id FOREIGN KEY (section_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3242 (class 2606 OID 25550)
-- Name: note fpk_note_note_class_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note
    ADD CONSTRAINT fpk_note_note_class_concept_id FOREIGN KEY (note_class_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3248 (class 2606 OID 25580)
-- Name: note fpk_note_note_event_field_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note
    ADD CONSTRAINT fpk_note_note_event_field_concept_id FOREIGN KEY (note_event_field_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3241 (class 2606 OID 25545)
-- Name: note fpk_note_note_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note
    ADD CONSTRAINT fpk_note_note_type_concept_id FOREIGN KEY (note_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3240 (class 2606 OID 25540)
-- Name: note fpk_note_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note
    ADD CONSTRAINT fpk_note_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3245 (class 2606 OID 25565)
-- Name: note fpk_note_provider_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note
    ADD CONSTRAINT fpk_note_provider_id FOREIGN KEY (provider_id) REFERENCES omopcdm.provider(provider_id);


--
-- TOC entry 3247 (class 2606 OID 25575)
-- Name: note fpk_note_visit_detail_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note
    ADD CONSTRAINT fpk_note_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES omopcdm.visit_detail(visit_detail_id);


--
-- TOC entry 3246 (class 2606 OID 25570)
-- Name: note fpk_note_visit_occurrence_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.note
    ADD CONSTRAINT fpk_note_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES omopcdm.visit_occurrence(visit_occurrence_id);


--
-- TOC entry 3235 (class 2606 OID 25515)
-- Name: observation fpk_observation_obs_event_field_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT fpk_observation_obs_event_field_concept_id FOREIGN KEY (obs_event_field_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3226 (class 2606 OID 25470)
-- Name: observation fpk_observation_observation_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT fpk_observation_observation_concept_id FOREIGN KEY (observation_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3234 (class 2606 OID 25510)
-- Name: observation fpk_observation_observation_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT fpk_observation_observation_source_concept_id FOREIGN KEY (observation_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3227 (class 2606 OID 25475)
-- Name: observation fpk_observation_observation_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT fpk_observation_observation_type_concept_id FOREIGN KEY (observation_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3159 (class 2606 OID 25135)
-- Name: observation_period fpk_observation_period_period_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation_period
    ADD CONSTRAINT fpk_observation_period_period_type_concept_id FOREIGN KEY (period_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3158 (class 2606 OID 25130)
-- Name: observation_period fpk_observation_period_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation_period
    ADD CONSTRAINT fpk_observation_period_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3225 (class 2606 OID 25465)
-- Name: observation fpk_observation_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT fpk_observation_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3231 (class 2606 OID 25495)
-- Name: observation fpk_observation_provider_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT fpk_observation_provider_id FOREIGN KEY (provider_id) REFERENCES omopcdm.provider(provider_id);


--
-- TOC entry 3229 (class 2606 OID 25485)
-- Name: observation fpk_observation_qualifier_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT fpk_observation_qualifier_concept_id FOREIGN KEY (qualifier_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3230 (class 2606 OID 25490)
-- Name: observation fpk_observation_unit_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT fpk_observation_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3228 (class 2606 OID 25480)
-- Name: observation fpk_observation_value_as_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT fpk_observation_value_as_concept_id FOREIGN KEY (value_as_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3233 (class 2606 OID 25505)
-- Name: observation fpk_observation_visit_detail_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT fpk_observation_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES omopcdm.visit_detail(visit_detail_id);


--
-- TOC entry 3232 (class 2606 OID 25500)
-- Name: observation fpk_observation_visit_occurrence_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.observation
    ADD CONSTRAINT fpk_observation_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES omopcdm.visit_occurrence(visit_occurrence_id);


--
-- TOC entry 3270 (class 2606 OID 25690)
-- Name: payer_plan_period fpk_payer_plan_period_payer_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.payer_plan_period
    ADD CONSTRAINT fpk_payer_plan_period_payer_concept_id FOREIGN KEY (payer_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3271 (class 2606 OID 25695)
-- Name: payer_plan_period fpk_payer_plan_period_payer_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.payer_plan_period
    ADD CONSTRAINT fpk_payer_plan_period_payer_source_concept_id FOREIGN KEY (payer_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3269 (class 2606 OID 25685)
-- Name: payer_plan_period fpk_payer_plan_period_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.payer_plan_period
    ADD CONSTRAINT fpk_payer_plan_period_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3272 (class 2606 OID 25700)
-- Name: payer_plan_period fpk_payer_plan_period_plan_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.payer_plan_period
    ADD CONSTRAINT fpk_payer_plan_period_plan_concept_id FOREIGN KEY (plan_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3273 (class 2606 OID 25705)
-- Name: payer_plan_period fpk_payer_plan_period_plan_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.payer_plan_period
    ADD CONSTRAINT fpk_payer_plan_period_plan_source_concept_id FOREIGN KEY (plan_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3274 (class 2606 OID 25710)
-- Name: payer_plan_period fpk_payer_plan_period_sponsor_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.payer_plan_period
    ADD CONSTRAINT fpk_payer_plan_period_sponsor_concept_id FOREIGN KEY (sponsor_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3275 (class 2606 OID 25715)
-- Name: payer_plan_period fpk_payer_plan_period_sponsor_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.payer_plan_period
    ADD CONSTRAINT fpk_payer_plan_period_sponsor_source_concept_id FOREIGN KEY (sponsor_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3276 (class 2606 OID 25720)
-- Name: payer_plan_period fpk_payer_plan_period_stop_reason_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.payer_plan_period
    ADD CONSTRAINT fpk_payer_plan_period_stop_reason_concept_id FOREIGN KEY (stop_reason_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3277 (class 2606 OID 25725)
-- Name: payer_plan_period fpk_payer_plan_period_stop_reason_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.payer_plan_period
    ADD CONSTRAINT fpk_payer_plan_period_stop_reason_source_concept_id FOREIGN KEY (stop_reason_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3154 (class 2606 OID 25110)
-- Name: person fpk_person_care_site_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.person
    ADD CONSTRAINT fpk_person_care_site_id FOREIGN KEY (care_site_id) REFERENCES omopcdm.care_site(care_site_id);


--
-- TOC entry 3151 (class 2606 OID 25095)
-- Name: person fpk_person_ethnicity_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.person
    ADD CONSTRAINT fpk_person_ethnicity_concept_id FOREIGN KEY (ethnicity_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3157 (class 2606 OID 25125)
-- Name: person fpk_person_ethnicity_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.person
    ADD CONSTRAINT fpk_person_ethnicity_source_concept_id FOREIGN KEY (ethnicity_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3149 (class 2606 OID 25085)
-- Name: person fpk_person_gender_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.person
    ADD CONSTRAINT fpk_person_gender_concept_id FOREIGN KEY (gender_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3155 (class 2606 OID 25115)
-- Name: person fpk_person_gender_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.person
    ADD CONSTRAINT fpk_person_gender_source_concept_id FOREIGN KEY (gender_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3152 (class 2606 OID 25100)
-- Name: person fpk_person_location_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.person
    ADD CONSTRAINT fpk_person_location_id FOREIGN KEY (location_id) REFERENCES omopcdm.location(location_id);


--
-- TOC entry 3153 (class 2606 OID 25105)
-- Name: person fpk_person_provider_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.person
    ADD CONSTRAINT fpk_person_provider_id FOREIGN KEY (provider_id) REFERENCES omopcdm.provider(provider_id);


--
-- TOC entry 3150 (class 2606 OID 25090)
-- Name: person fpk_person_race_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.person
    ADD CONSTRAINT fpk_person_race_concept_id FOREIGN KEY (race_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3156 (class 2606 OID 25120)
-- Name: person fpk_person_race_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.person
    ADD CONSTRAINT fpk_person_race_source_concept_id FOREIGN KEY (race_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3199 (class 2606 OID 25335)
-- Name: procedure_occurrence fpk_procedure_occurrence_modifier_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_occurrence_modifier_concept_id FOREIGN KEY (modifier_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3196 (class 2606 OID 25320)
-- Name: procedure_occurrence fpk_procedure_occurrence_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_occurrence_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3197 (class 2606 OID 25325)
-- Name: procedure_occurrence fpk_procedure_occurrence_procedure_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_occurrence_procedure_concept_id FOREIGN KEY (procedure_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3203 (class 2606 OID 25355)
-- Name: procedure_occurrence fpk_procedure_occurrence_procedure_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_occurrence_procedure_source_concept_id FOREIGN KEY (procedure_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3198 (class 2606 OID 25330)
-- Name: procedure_occurrence fpk_procedure_occurrence_procedure_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_occurrence_procedure_type_concept_id FOREIGN KEY (procedure_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3200 (class 2606 OID 25340)
-- Name: procedure_occurrence fpk_procedure_occurrence_provider_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_occurrence_provider_id FOREIGN KEY (provider_id) REFERENCES omopcdm.provider(provider_id);


--
-- TOC entry 3202 (class 2606 OID 25350)
-- Name: procedure_occurrence fpk_procedure_occurrence_visit_detail_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_occurrence_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES omopcdm.visit_detail(visit_detail_id);


--
-- TOC entry 3201 (class 2606 OID 25345)
-- Name: procedure_occurrence fpk_procedure_occurrence_visit_occurrence_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_occurrence_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES omopcdm.visit_occurrence(visit_occurrence_id);


--
-- TOC entry 3265 (class 2606 OID 25665)
-- Name: provider fpk_provider_care_site_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.provider
    ADD CONSTRAINT fpk_provider_care_site_id FOREIGN KEY (care_site_id) REFERENCES omopcdm.care_site(care_site_id);


--
-- TOC entry 3266 (class 2606 OID 25670)
-- Name: provider fpk_provider_gender_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.provider
    ADD CONSTRAINT fpk_provider_gender_concept_id FOREIGN KEY (gender_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3268 (class 2606 OID 25680)
-- Name: provider fpk_provider_gender_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.provider
    ADD CONSTRAINT fpk_provider_gender_source_concept_id FOREIGN KEY (gender_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3264 (class 2606 OID 25660)
-- Name: provider fpk_provider_specialty_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.provider
    ADD CONSTRAINT fpk_provider_specialty_concept_id FOREIGN KEY (specialty_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3267 (class 2606 OID 25675)
-- Name: provider fpk_provider_specialty_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.provider
    ADD CONSTRAINT fpk_provider_specialty_source_concept_id FOREIGN KEY (specialty_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3310 (class 2606 OID 25890)
-- Name: relationship fpk_relationship_relationship_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.relationship
    ADD CONSTRAINT fpk_relationship_relationship_concept_id FOREIGN KEY (relationship_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3315 (class 2606 OID 25915)
-- Name: source_to_concept_map fpk_source_to_concept_map_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.source_to_concept_map
    ADD CONSTRAINT fpk_source_to_concept_map_source_concept_id FOREIGN KEY (source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3316 (class 2606 OID 25920)
-- Name: source_to_concept_map fpk_source_to_concept_map_target_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.source_to_concept_map
    ADD CONSTRAINT fpk_source_to_concept_map_target_concept_id FOREIGN KEY (target_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3317 (class 2606 OID 25925)
-- Name: source_to_concept_map fpk_source_to_concept_map_target_vocabulary_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.source_to_concept_map
    ADD CONSTRAINT fpk_source_to_concept_map_target_vocabulary_id FOREIGN KEY (target_vocabulary_id) REFERENCES omopcdm.vocabulary(vocabulary_id);


--
-- TOC entry 3256 (class 2606 OID 25620)
-- Name: specimen fpk_specimen_anatomic_site_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.specimen
    ADD CONSTRAINT fpk_specimen_anatomic_site_concept_id FOREIGN KEY (anatomic_site_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3257 (class 2606 OID 25625)
-- Name: specimen fpk_specimen_disease_status_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.specimen
    ADD CONSTRAINT fpk_specimen_disease_status_concept_id FOREIGN KEY (disease_status_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3252 (class 2606 OID 25600)
-- Name: specimen fpk_specimen_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.specimen
    ADD CONSTRAINT fpk_specimen_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3253 (class 2606 OID 25605)
-- Name: specimen fpk_specimen_specimen_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.specimen
    ADD CONSTRAINT fpk_specimen_specimen_concept_id FOREIGN KEY (specimen_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3254 (class 2606 OID 25610)
-- Name: specimen fpk_specimen_specimen_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.specimen
    ADD CONSTRAINT fpk_specimen_specimen_type_concept_id FOREIGN KEY (specimen_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3255 (class 2606 OID 25615)
-- Name: specimen fpk_specimen_unit_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.specimen
    ADD CONSTRAINT fpk_specimen_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3175 (class 2606 OID 25215)
-- Name: visit_detail fpk_visit_detail_admitted_from_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT fpk_visit_detail_admitted_from_concept_id FOREIGN KEY (admitted_from_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3173 (class 2606 OID 25205)
-- Name: visit_detail fpk_visit_detail_care_site_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT fpk_visit_detail_care_site_id FOREIGN KEY (care_site_id) REFERENCES omopcdm.care_site(care_site_id);


--
-- TOC entry 3176 (class 2606 OID 25220)
-- Name: visit_detail fpk_visit_detail_discharged_to_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT fpk_visit_detail_discharged_to_concept_id FOREIGN KEY (discharged_to_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3178 (class 2606 OID 25230)
-- Name: visit_detail fpk_visit_detail_parent_visit_detail_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT fpk_visit_detail_parent_visit_detail_id FOREIGN KEY (parent_visit_detail_id) REFERENCES omopcdm.visit_detail(visit_detail_id);


--
-- TOC entry 3169 (class 2606 OID 25185)
-- Name: visit_detail fpk_visit_detail_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT fpk_visit_detail_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3177 (class 2606 OID 25225)
-- Name: visit_detail fpk_visit_detail_preceding_visit_detail_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT fpk_visit_detail_preceding_visit_detail_id FOREIGN KEY (preceding_visit_detail_id) REFERENCES omopcdm.visit_detail(visit_detail_id);


--
-- TOC entry 3172 (class 2606 OID 25200)
-- Name: visit_detail fpk_visit_detail_provider_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT fpk_visit_detail_provider_id FOREIGN KEY (provider_id) REFERENCES omopcdm.provider(provider_id);


--
-- TOC entry 3170 (class 2606 OID 25190)
-- Name: visit_detail fpk_visit_detail_visit_detail_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT fpk_visit_detail_visit_detail_concept_id FOREIGN KEY (visit_detail_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3174 (class 2606 OID 25210)
-- Name: visit_detail fpk_visit_detail_visit_detail_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT fpk_visit_detail_visit_detail_source_concept_id FOREIGN KEY (visit_detail_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3171 (class 2606 OID 25195)
-- Name: visit_detail fpk_visit_detail_visit_detail_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT fpk_visit_detail_visit_detail_type_concept_id FOREIGN KEY (visit_detail_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3179 (class 2606 OID 25235)
-- Name: visit_detail fpk_visit_detail_visit_occurrence_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_detail
    ADD CONSTRAINT fpk_visit_detail_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES omopcdm.visit_occurrence(visit_occurrence_id);


--
-- TOC entry 3166 (class 2606 OID 25170)
-- Name: visit_occurrence fpk_visit_occurrence_admitted_from_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_occurrence
    ADD CONSTRAINT fpk_visit_occurrence_admitted_from_concept_id FOREIGN KEY (admitted_from_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3164 (class 2606 OID 25160)
-- Name: visit_occurrence fpk_visit_occurrence_care_site_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_occurrence
    ADD CONSTRAINT fpk_visit_occurrence_care_site_id FOREIGN KEY (care_site_id) REFERENCES omopcdm.care_site(care_site_id);


--
-- TOC entry 3167 (class 2606 OID 25175)
-- Name: visit_occurrence fpk_visit_occurrence_discharged_to_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_occurrence
    ADD CONSTRAINT fpk_visit_occurrence_discharged_to_concept_id FOREIGN KEY (discharged_to_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3160 (class 2606 OID 25140)
-- Name: visit_occurrence fpk_visit_occurrence_person_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_occurrence
    ADD CONSTRAINT fpk_visit_occurrence_person_id FOREIGN KEY (person_id) REFERENCES omopcdm.person(person_id);


--
-- TOC entry 3168 (class 2606 OID 25180)
-- Name: visit_occurrence fpk_visit_occurrence_preceding_visit_occurrence_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_occurrence
    ADD CONSTRAINT fpk_visit_occurrence_preceding_visit_occurrence_id FOREIGN KEY (preceding_visit_occurrence_id) REFERENCES omopcdm.visit_occurrence(visit_occurrence_id);


--
-- TOC entry 3163 (class 2606 OID 25155)
-- Name: visit_occurrence fpk_visit_occurrence_provider_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_occurrence
    ADD CONSTRAINT fpk_visit_occurrence_provider_id FOREIGN KEY (provider_id) REFERENCES omopcdm.provider(provider_id);


--
-- TOC entry 3161 (class 2606 OID 25145)
-- Name: visit_occurrence fpk_visit_occurrence_visit_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_occurrence
    ADD CONSTRAINT fpk_visit_occurrence_visit_concept_id FOREIGN KEY (visit_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3165 (class 2606 OID 25165)
-- Name: visit_occurrence fpk_visit_occurrence_visit_source_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_occurrence
    ADD CONSTRAINT fpk_visit_occurrence_visit_source_concept_id FOREIGN KEY (visit_source_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3162 (class 2606 OID 25150)
-- Name: visit_occurrence fpk_visit_occurrence_visit_type_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.visit_occurrence
    ADD CONSTRAINT fpk_visit_occurrence_visit_type_concept_id FOREIGN KEY (visit_type_concept_id) REFERENCES omopcdm.concept(concept_id);


--
-- TOC entry 3304 (class 2606 OID 25860)
-- Name: vocabulary fpk_vocabulary_vocabulary_concept_id; Type: FK CONSTRAINT; Schema: omopcdm; Owner: postgres
--

ALTER TABLE ONLY omopcdm.vocabulary
    ADD CONSTRAINT fpk_vocabulary_vocabulary_concept_id FOREIGN KEY (vocabulary_concept_id) REFERENCES omopcdm.concept(concept_id);


-- Completed on 2025-06-09 19:16:09 CEST

--
-- PostgreSQL database dump complete
--

