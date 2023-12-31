<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<mapper namespace="${daoClass.pkg}.${daoClass.className}">

    <#assign baseTypes=["Integer","Long","Boolean", "String", "Date", "BigDecimal", "Decimal"] >
    <#list resultMaps as k,resultMap>
        <#if baseTypes?seqContains(resultMap.className) >

        <#else>
            <resultMap id="${resultMap.className}" type="${resultMap.pkg}.${resultMap.className}">
                <#list resultMap.fields as field>
                    <#if field.name=="id">
                        <id column="${field.column}" property="${field.name}"/>
                    <#else>
                        <result column="${field.column}" property="${field.name}"/>
                    </#if>
                </#list>
            </resultMap>
        </#if>
    </#list>
    <#list daoClass.methods as method>
        <#if method.name?startsWith("add")>
            <#assign columns = method.inputClass.fields?map(field -> field.column)>
            <#assign values = method.inputClass.fields?map(field -> "#{"+field.name+"}")>
            <insert id="${method.name}" useGeneratedKeys="true" keyProperty="id" keyColumn="id">
                INSERT INTO ${daoClass.tableName}(${columns?join(", ")})
                values (${values?join(", ")})
            </insert>
        </#if>
        <#if method.name?startsWith("get")>
            <#assign columns = method.outputClass.fields?map(field -> field.column)>
            <#assign conds = method.inputClass.fields?map(field -> field.name+"=#{"+field.name+"}")>
            <select id="${method.name}" <#if baseTypes?seqContains(method.outputClass.className)>resultType="${method.outputClass.className}"<#else>resultMap="${method.outputClass.className}"</#if> >
                SELECT ${columns?join(", ")}
                FROM ${daoClass.tableName}
                WHERE
                   <#if baseTypes?seqContains(method.inputClass.className)>
                       ${conds?join(" AND ")}
                   </#if>
            </select>
        </#if>
        <#if method.name?startsWith("update")>
            <#assign columns = method.inputClass.fields?filter(e -> e.name != "id")?map(field -> field.name+"=#{"+field.name+"}")>
            <update id="${method.name}" <#if baseTypes?seqContains(method.outputClass.className)>resultType="${method.outputClass.className}"<#else>resultMap="${method.outputClass.className}"</#if> >
                UPDATE ${daoClass.tableName}
                SET  ${columns?join(", ")}
                WHERE
                id=${r'#{id}'}
            </update>
        </#if>
        <#if method.name?startsWith("search")>
            <sql id="${method.name}Cond">
                <where>
                    <trim prefixOverrides="AND">
                    <#list method.inputClass.fields as field>
                        <#if field.javaType == "String">
                            <if test="${field.name}!=null and !${field.name}.isEmpty()">
                                AND ${field.column}=${r'#{'}${field.name}${r'}'}
                            </if>
                        <#else>
                            <if test="${field.name}!=null">
                                AND ${field.column}=${r'#{'}${field.name}${r'}'}
                            </if>
                        </#if>
                    </#list>
                </trim>

                </where>
            </sql>
            <#assign columns = method.outputClass.fields?map(field -> field.column)>
            <#assign conds = method.inputClass.fields?map(field -> field.name+"=#{"+field.name+"}")>
            <select id="${method.name}" <#if baseTypes?seqContains(method.outputClass.className)>resultType="${method.outputClass.className}"<#else>resultMap="${method.outputClass.className}"</#if> >
                SELECT ${columns?join(", ")}
                FROM ${daoClass.tableName}
                <include refid="${method.name}Cond"/>
            </select>
            <select id="get${method.name?capitalize}Count" <#if baseTypes?seqContains(method.outputClass.className)>resultType="${method.outputClass.className}"<#else>resultType="java.lang.Integer"</#if> >
                SELECT count(1)
                FROM ${daoClass.tableName}
                <include refid="${method.name}Cond"/>
            </select>
        </#if>
    </#list>
</mapper>