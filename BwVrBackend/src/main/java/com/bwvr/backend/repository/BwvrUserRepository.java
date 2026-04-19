package com.bwvr.backend.repository;

import com.bwvr.backend.entity.BwvrUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BwvrUserRepository extends JpaRepository<BwvrUser, Long> {
    Optional<BwvrUser> findByUsername(String username);
    List<BwvrUser> findByStatus(String status);
}
